#!/bin/bash
set -euo pipefail

# Test hooks: every host path below is relative to HPDS_DEPLOY_ROOT (default /),
# and the aws binary can be overridden. Production leaves both unset.
DEPLOY_ROOT="${HPDS_DEPLOY_ROOT:-/}"
DEPLOY_ROOT="${DEPLOY_ROOT%/}"
AWS_BIN="${HPDS_AWS_BIN:-/usr/bin/aws}"
HPDS_DIR="${DEPLOY_ROOT}/opt/local/hpds"

while [[ $# -gt 0 ]]; do
  case $1 in
    --stack_s3_bucket)
      stack_s3_bucket="$2"
      shift 2
      ;;
   --dataset_s3_object_key)
      dataset_s3_object_key="$2"
      shift 2
      ;;
    --genomic_dataset_s3_object_key)
      genomic_dataset_s3_object_key="$2"
      shift 2
      ;;
    --environment_name)
      environment_name="$2"
      shift 2
      ;;
    --target_stack)
      target_stack="$2"
      shift 2
      ;;
    --env_private_dns_name)
      env_private_dns_name="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Source /etc/environment for fallback values (set during initial provisioning)
if [[ -f "${DEPLOY_ROOT}/etc/environment" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${DEPLOY_ROOT}/etc/environment"
  set +a
fi

stack_s3_bucket=${stack_s3_bucket:-${STACK_S3_BUCKET:-}}
dataset_s3_object_key=${dataset_s3_object_key:-${DATASET_S3_OBJECT_KEY:-}}
genomic_dataset_s3_object_key=${genomic_dataset_s3_object_key:-${GENOMIC_DATASET_S3_OBJECT_KEY:-}}
target_stack=${target_stack:-${TARGET_STACK:-}}
environment_name=${environment_name:-${ENVIRONMENT_NAME:-}}
env_private_dns_name=${env_private_dns_name:-${ENV_PRIVATE_DNS_NAME:-}}



if [[ -z "$stack_s3_bucket" || -z "$genomic_dataset_s3_object_key" || -z "$dataset_s3_object_key" || -z "$environment_name" || -z "$target_stack" || -z "$env_private_dns_name" ]]; then
  echo "Error: --stack_s3_bucket, --genomic_dataset_s3_object_key, --dataset_s3_object_key, --environment_name, --target_stack, and --env_private_dns_name are required"
  exit 1
fi

# Determine whether the dataset keys changed since the previous run.
# A missing last-execution file means this is the first run — always download.
download_dataset=true
download_genomic_dataset=true
last_execution_file="${DEPLOY_ROOT}/opt/picsure/deploy-script-last-execution-values.txt"
if [[ -f "$last_execution_file" ]]; then
  prev_dataset_s3_object_key=$(awk -F'"' '/^export dataset_s3_object_key=/{print $2}' "$last_execution_file")
  prev_genomic_dataset_s3_object_key=$(awk -F'"' '/^export genomic_dataset_s3_object_key=/{print $2}' "$last_execution_file")
  if [[ "$prev_dataset_s3_object_key" == "$dataset_s3_object_key" ]]; then
    download_dataset=false
  fi
  if [[ "$prev_genomic_dataset_s3_object_key" == "$genomic_dataset_s3_object_key" ]]; then
    download_genomic_dataset=false
  fi
fi

# Fail closed: if all attempts fail, abort the deploy rather than continuing
# with whatever stale file is already on disk.
s3_copy() {
  for _ in {1..5}; do
    sudo "$AWS_BIN" --region us-east-1 s3 cp "$@" --no-progress && return 0
    sleep 30
  done
  echo "ERROR: aws s3 cp failed after 5 attempts: $*" >&2
  exit 1
}

# ---------------------------------------------------------------------------
# Per-file staged dataset deploy (bdc-hpds-deploy/1, see the HPDS pheno release
# contract). This block is IDENTICAL in deploy-auth-hpds.sh and deploy-open-hpds.sh:
# the user_data scripts download exactly one deploy-*.sh each from S3 (and the
# instance role may only read that one object), so there is no shared helper file.
# Callers set HPDS_VARIANT, STAGE_PREFIX, LEGACY_TAR and CONTAINER_NAME first.
# ---------------------------------------------------------------------------
die() {
  echo "ERROR: $*" >&2
  exit 1
}

# True when the variant's own manifest.tsv is staged for the dataset key. Detect
# by listing (ListBucket on data/* is granted; HeadObject on a missing key may be 403).
staged_manifest_exists() {
  local manifest_key="data/$1/${STAGE_PREFIX}manifest.tsv" listing
  for _ in {1..5}; do
    if listing=$(sudo "$AWS_BIN" --region us-east-1 s3api list-objects-v2 --bucket "$stack_s3_bucket" \
      --prefix "$manifest_key" --query 'Contents[].Key' --output text); then
      tr '\t' '\n' <<<"$listing" | grep -Fxq "$manifest_key" && return 0
      return 1
    fi
    sleep 30
  done
  die "could not list s3://${stack_s3_bucket}/${manifest_key} after 5 attempts"
}

valid_dest() {
  local dest=$1 seg
  local -a segs
  [[ "$dest" =~ ^[A-Za-z0-9._/-]+$ ]] || return 1
  [[ "$dest" != /* && "$dest" != */ ]] || return 1
  IFS=/ read -ra segs <<<"$dest"
  for seg in "${segs[@]}"; do
    [[ -n "$seg" && "$seg" != "." && "$seg" != ".." ]] || return 1
  done
  # all/ is the genomic dataset; .incoming is our staging area.
  [[ "$dest" != "all" && "$dest" != all/* && "$dest" != ".incoming" && "$dest" != .incoming/* ]] || return 1
  return 0
}

file_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

# Copy the variant's staged files into /opt/local/hpds. Any failure exits non-zero
# before anything is moved into place.
deploy_per_file_dataset() {
  local dataset_key=$1
  local prefix="s3://${stack_s3_bucket}/data/${dataset_key}/${STAGE_PREFIX}"
  local incoming="${HPDS_DIR}/.incoming"
  local manifest="${DEPLOY_ROOT}/opt/picsure/manifest-${HPDS_VARIANT}.tsv"
  local line lineno=0 variant_seen="" header_seen=false
  local dest bytes sha etag src
  local -a dests=() sizes=() shas=()
  local total=0 need avail_kb idx actual running seen seen_dests=""

  echo "Per-file staged dataset found: ${prefix}manifest.tsv"
  mkdir -p "${DEPLOY_ROOT}/opt/picsure" "$HPDS_DIR"
  rm -rf "$incoming"
  trap 'rm -rf "${HPDS_DIR}/.incoming"' EXIT
  mkdir -p "$incoming"

  s3_copy "${prefix}manifest.tsv" "$manifest"

  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$((lineno + 1))
    if [[ $lineno -eq 1 ]]; then
      [[ "$line" == "# bdc-hpds-deploy/1" ]] || die "manifest.tsv line 1 is not '# bdc-hpds-deploy/1'"
      continue
    fi
    if [[ "$line" == "#"* ]]; then
      [[ "$line" != "# variant="* ]] || variant_seen=${line#"# variant="}
      continue
    fi
    if [[ "$header_seen" == "false" ]]; then
      [[ "$line" == $'dest\tbytes\tsha256\tetag\tsrc' ]] || die "manifest.tsv has no 'dest bytes sha256 etag src' header line"
      [[ "$variant_seen" == "$HPDS_VARIANT" ]] || die "manifest.tsv is for variant '${variant_seen}', this host deploys '${HPDS_VARIANT}'"
      header_seen=true
      continue
    fi
    IFS=$'\t' read -r dest bytes sha etag src <<<"$line"
    [[ -n "$dest" && -n "$bytes" && -n "$sha" && -n "$etag" && -n "$src" ]] || die "manifest.tsv line ${lineno} is incomplete"
    valid_dest "$dest" || die "unsafe dest in manifest.tsv line ${lineno}: ${dest}"
    [[ "$bytes" =~ ^[0-9]+$ ]] || die "bad bytes in manifest.tsv line ${lineno}: ${bytes}"
    [[ "$sha" == "-" || "$sha" =~ ^[0-9a-f]{64}$ ]] || die "bad sha256 in manifest.tsv line ${lineno}: ${sha}"
    [[ ! -d "${HPDS_DIR}/${dest}" ]] || die "dest is a directory on this host: ${dest}"
    ! grep -Fxq "$dest" <<<"$seen_dests" || die "duplicate dest in manifest.tsv: ${dest}"
    seen_dests+="${dest}"$'\n'
    dests+=("$dest")
    sizes+=("$bytes")
    shas+=("$sha")
    total=$((total + bytes))
  done <"$manifest"

  [[ "$header_seen" == "true" ]] || die "manifest.tsv has no header line"
  [[ ${#dests[@]} -gt 0 ]] || die "manifest.tsv lists no files"
  for seen in allObservationsStore.javabin columnMeta.javabin; do
    grep -Fxq "$seen" <<<"$seen_dests" || die "manifest.tsv does not list ${seen}"
  done

  # Staged copies exist next to the live ones until everything is verified.
  need=$((total + total / 10))
  avail_kb=$(df -Pk "$HPDS_DIR" | awk 'NR==2{print $4}')
  [[ "$avail_kb" =~ ^[0-9]+$ ]] || die "could not read free space of ${HPDS_DIR}"
  if ((avail_kb * 1024 < need)); then
    die "not enough free space in ${HPDS_DIR}: need ${need} bytes (total ${total} + 10%), have $((avail_kb * 1024))"
  fi

  for idx in "${!dests[@]}"; do
    dest=${dests[$idx]}
    mkdir -p "$(dirname "${incoming}/${dest}")"
    s3_copy "${prefix}${dest}" "${incoming}/${dest}"
    actual=$(wc -c <"${incoming}/${dest}" | tr -d '[:space:]')
    [[ "$actual" == "${sizes[$idx]}" ]] || die "size mismatch for ${dest}: manifest ${sizes[$idx]}, downloaded ${actual}"
    if [[ "${shas[$idx]}" != "-" ]]; then
      actual=$(file_sha256 "${incoming}/${dest}")
      [[ "$actual" == "${shas[$idx]}" ]] || die "sha256 mismatch for ${dest}: manifest ${shas[$idx]}, downloaded ${actual}"
    fi
    echo "Verified ${dest} (${sizes[$idx]} bytes)"
  done

  # Everything verified: stop the running HPDS so it never reads a half-replaced set.
  running=$(podman ps --format '{{.Names}}' || true)
  if grep -Fxq "$CONTAINER_NAME" <<<"$running"; then
    echo "Stopping running container ${CONTAINER_NAME} before replacing files"
    sudo systemctl stop "container-${CONTAINER_NAME}.service" 2>/dev/null || true
    podman stop "$CONTAINER_NAME" || true
    running=$(podman ps --format '{{.Names}}' || true)
    ! grep -Fxq "$CONTAINER_NAME" <<<"$running" || die "container ${CONTAINER_NAME} is still running; not replacing files"
  fi

  for dest in "${dests[@]}"; do
    mkdir -p "$(dirname "${HPDS_DIR}/${dest}")"
    mv -f "${incoming}/${dest}" "${HPDS_DIR}/${dest}"
  done
  rm -f "${HPDS_DIR}/${LEGACY_TAR}"
  trap - EXIT
  rm -rf "$incoming"
  echo "Deployed ${#dests[@]} files for variant ${HPDS_VARIANT} into ${HPDS_DIR}"
}

HPDS_VARIANT=auth
STAGE_PREFIX=javabins_rekeyed/
LEGACY_TAR=javabins_rekeyed.tar
CONTAINER_NAME="auth-hpds"

s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-hpds.tar.gz" "${DEPLOY_ROOT}/opt/picsure/pic-sure-hpds.tar.gz"
s3_copy "s3://${stack_s3_bucket}/configs/hpds/${target_stack}/auth-hpds.env" "${DEPLOY_ROOT}/opt/picsure/auth-hpds.env"

if [[ "$download_dataset" == "true" ]]; then
  if staged_manifest_exists "$dataset_s3_object_key"; then
    deploy_per_file_dataset "$dataset_s3_object_key"
  else
    echo "No per-file manifest for ${dataset_s3_object_key}; using the legacy ${LEGACY_TAR}"
    s3_copy "s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/${LEGACY_TAR}" "${HPDS_DIR}/${LEGACY_TAR}"
    cd "$HPDS_DIR" || exit 1
    tar -xvf "$LEGACY_TAR"
    cd ~ || exit 1
  fi
else
  echo "Skipping javabins download — dataset_s3_object_key unchanged from previous run (${dataset_s3_object_key})"
fi

if [[ "$download_genomic_dataset" == "true" ]]; then
  s3_copy "s3://${stack_s3_bucket}/data/${genomic_dataset_s3_object_key}/all/" "${HPDS_DIR}/all/" --recursive
else
  echo "Skipping genomic dataset download — genomic_dataset_s3_object_key unchanged from previous run (${genomic_dataset_s3_object_key})"
fi

# Record values only after downloads so a failed run doesn't cause the next run
# to incorrectly skip redownloading.
cat << EOF > "$last_execution_file"
export stack_s3_bucket="${stack_s3_bucket}"
export dataset_s3_object_key="${dataset_s3_object_key}"
export genomic_dataset_s3_object_key="${genomic_dataset_s3_object_key}"
export environment_name="${environment_name}"
export target_stack="${target_stack}"
export env_private_dns_name="${env_private_dns_name}"
EOF

# chmod only regular files: a glob (e.g. /opt/local/hpds/all/*) matches nothing
# when the genomic dataset is empty/absent, and under set -e that aborts the whole
# deploy. find is a no-op on an empty tree and skips directories (leaving all/
# traversable).
find "$HPDS_DIR" -type f -exec chmod 644 {} +
chmod 644 "${DEPLOY_ROOT}/opt/picsure/auth-hpds.env"
chmod 644 "${DEPLOY_ROOT}/opt/picsure/pic-sure-hpds.tar.gz"

echo "Loading and running container"
HPDS_IMAGE=$(podman load < "${DEPLOY_ROOT}/opt/picsure/pic-sure-hpds.tar.gz" | cut -d ' ' -f 3)

# Stop and remove any existing container and systemd service.
sudo systemctl stop container-$CONTAINER_NAME.service 2>/dev/null || true
podman rm -f $CONTAINER_NAME || true

# Create the container without starting it — systemd will handle startup.
podman create --privileged --name=$CONTAINER_NAME \
                -v /var/log/picsure/auth-hpds/:/var/log/:Z \
                -v "${HPDS_DIR}:/opt/local/hpds:Z" \
                --log-opt tag=$CONTAINER_NAME \
                -p 8080:8080 \
                --env-file "${DEPLOY_ROOT}/opt/picsure/auth-hpds.env" \
                "$HPDS_IMAGE"

# systemd setup.
podman generate systemd --name $CONTAINER_NAME --restart-policy=always --files
sudo mv container-$CONTAINER_NAME.service "${DEPLOY_ROOT}/etc/systemd/system/"
sudo restorecon -v "${DEPLOY_ROOT}/etc/systemd/system/container-$CONTAINER_NAME.service"

sudo systemctl daemon-reload
sudo systemctl enable container-$CONTAINER_NAME.service
sudo systemctl start --no-block container-$CONTAINER_NAME.service

echo "Verifying container-$CONTAINER_NAME.service status..."
sudo systemctl is-enabled container-$CONTAINER_NAME.service
# Status check is informational — Jenkins log polling verifies actual startup.
sudo systemctl status container-$CONTAINER_NAME.service --no-pager || true

# Give systemd a moment to start the container, then fail the script if it is
# not running, so Jenkins reports the real error.
sleep 10
if ! podman ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "ERROR: Container '$CONTAINER_NAME' is not running after startup."
  echo "--- Full container inspect ---"
  podman inspect $CONTAINER_NAME 2>&1 || true
  exit 1
fi
