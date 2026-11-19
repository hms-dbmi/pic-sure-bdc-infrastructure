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

# >>> shared HPDS dataset block: identical in deploy-auth-hpds.sh and deploy-open-hpds.sh >>>
# Per-file staged dataset deploy (bdc-hpds-deploy/1, flat or layout=partitioned; see
# the HPDS pheno release contracts). The user_data scripts download exactly one
# deploy-*.sh each from S3 (and the instance role may only read that one object), so
# there is no shared helper file: this block is copied into both scripts and a test
# keeps the two copies identical.
# Callers set HPDS_VARIANT, STAGE_PREFIX, LEGACY_TAR, CONTAINER_NAME and
# HPDS_REQUIRE_AUTH_FILTER (true on the auth host, false on the open host) first.
HPDS_LAYOUT=flat

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
  # all/ is the genomic dataset; .incoming and .previous-phenotypic are our staging
  # areas; manifest.tsv is the downloaded manifest inside .incoming.
  [[ "$dest" != "all" && "$dest" != all/* && "$dest" != ".incoming" && "$dest" != .incoming/* ]] || return 1
  [[ "$dest" != ".previous-phenotypic" && "$dest" != .previous-phenotypic/* && "$dest" != "manifest.tsv" ]] || return 1
  return 0
}

valid_partition_name() {
  [[ "$1" =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$ ]]
}

file_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

# Print flat or partitioned from the "# layout=" header of a manifest.tsv (no header =
# flat, anything else is an error).
read_manifest_layout() {
  local value
  value=$(awk '/^# layout=/{sub(/^# layout=/, ""); print; exit}' "$1")
  case "$value" in
    "") echo flat ;;
    partitioned) echo partitioned ;;
    *) die "unknown layout '${value}' in $1" ;;
  esac
}

# Start of every run. A leftover .previous-phenotypic means a run died while it was
# replacing the partitioned set: with no phenotypic/ the old set is renamed back,
# otherwise the leftover is removed. A leftover .incoming is removed. Returns 10 when
# either leftover was found, so the caller ignores "dataset key unchanged" and does a
# full download (the kept manifest then matches what is on disk); 0 otherwise.
recover_interrupted_swap() {
  local previous="${HPDS_DIR:?}/.previous-phenotypic" incoming="${HPDS_DIR:?}/.incoming" dirty=0
  if [[ -e "$previous" || -L "$previous" ]]; then
    dirty=1
    if [[ ! -e "${HPDS_DIR}/phenotypic" ]]; then
      echo "A previous run died while replacing the partitioned set: restoring ${previous}"
      mv "$previous" "${HPDS_DIR}/phenotypic" || die "could not rename ${previous} back to phenotypic"
    else
      echo "Removing leftover ${previous} from an interrupted run"
      rm -rf "${previous:?}"
    fi
  fi
  if [[ -e "$incoming" || -L "$incoming" ]]; then
    dirty=1
    echo "Removing leftover ${incoming} from an interrupted run"
    rm -rf "${incoming:?}"
  fi
  [[ $dirty -eq 0 ]] || return 10
  return 0
}

# Auth host: HPDS must never run with the authorization filter off. Refuse an env
# file in which ANY mention of requireAuthorizationFilter (any case, any line, a -D
# token, the env-var form or a JSON key) has a value other than exactly true. Every
# mention is checked at its own position, so a later mention cannot vouch for an
# earlier one.
refuse_filter_not_true() {
  local env_file=$1 line rest lc pre tail value="" re_plain re_json
  re_plain="^requireAuthorizationFilter[[:space:]]*[=:][[:space:]]*[\"']?([^[:space:]\"']*)"
  re_json="^requireAuthorizationFilter[\"'][[:space:]]*[=:][[:space:]]*[\"']?([^][:space:]\"',}]*)"
  while IFS= read -r line || [[ -n "$line" ]]; do
    rest=$line
    while true; do
      lc=$(printf '%s' "$rest" | tr '[:upper:]' '[:lower:]')
      pre=${lc%%requireauthorizationfilter*}
      [[ "$pre" != "$lc" ]] || break
      tail=${rest:${#pre}}
      shopt -s nocasematch
      if [[ "${tail:26:1}" == '"' || "${tail:26:1}" == "'" ]]; then
        [[ "$tail" =~ $re_json ]] || value="?"
      else
        [[ "$tail" =~ $re_plain ]] || value="?"
      fi
      shopt -u nocasematch
      if [[ "${value:-}" == "?" ]]; then
        die "${env_file} names requireAuthorizationFilter without a value that can be checked; refusing to deploy the auth host"
      fi
      value=${BASH_REMATCH[1]}
      [[ "$value" == "true" ]] || die "${env_file} sets requireAuthorizationFilter to '${value}'; the auth host must run with it true, refusing to deploy"
      rest=${tail:${#BASH_REMATCH[0]}}
    done
  done <"$env_file"
}

# Edit the local copy of the stack env file (it is downloaded again on every run):
# append the authorization filter property to JAVA_OPTS (the line is added when
# absent) and, for a partitioned layout, point HPDS at phenotypic/.
apply_env_settings() {
  local layout=$1 env_file="${DEPLOY_ROOT}/opt/picsure/${HPDS_VARIANT}-hpds.env" data_dir=""
  [[ "$layout" != "partitioned" ]] || data_dir="/opt/local/hpds/phenotypic/"
  awk -v opt=" -Dhpds.requireAuthorizationFilter=${HPDS_REQUIRE_AUTH_FILTER}" -v data_dir="$data_dir" '
    /^JAVA_OPTS=/ {
      found = 1
      line = $0
      n = length(line)
      q = substr(line, n, 1)
      if (n >= 12 && (q == "\"" || q == "\047") && substr(line, 11, 1) == q) {
        line = substr(line, 1, n - 1) opt q
      } else {
        line = line opt
      }
      print line
      next
    }
    data_dir != "" && /^HPDS_DATA_DIRECTORY=/ { print "HPDS_DATA_DIRECTORY=" data_dir; dir_set = 1; next }
    { print }
    END {
      if (!found) print "JAVA_OPTS=" substr(opt, 2)
      if (data_dir != "" && !dir_set) print "HPDS_DATA_DIRECTORY=" data_dir
    }' "$env_file" >"${env_file}.new" || die "could not edit ${env_file}"
  mv -f "${env_file}.new" "$env_file"
  echo "Container settings (${layout} layout): requireAuthorizationFilter=${HPDS_REQUIRE_AUTH_FILTER}${data_dir:+, HPDS_DATA_DIRECTORY=${data_dir}}"
}

# Shape of a partitioned manifest.tsv: <dests> is the newline-separated dest list.
check_partitioned_shape() {
  local dests=$1 declared=$2 dest part kind n_key=0 n_meta=0 stores="" metas="" distinct
  local re='^phenotypic/([^/]+)/(allObservationsStore|columnMeta)\.javabin$'
  while IFS= read -r dest; do
    [[ -n "$dest" ]] || continue
    if [[ "$dest" == "encryption_key" ]]; then
      n_key=$((n_key + 1))
    elif [[ "$dest" == "metadata.json" ]]; then
      n_meta=$((n_meta + 1))
    elif [[ "$dest" =~ $re ]]; then
      part=${BASH_REMATCH[1]}
      kind=${BASH_REMATCH[2]}
      valid_partition_name "$part" || die "bad partition name in manifest.tsv: ${part}"
      if [[ "$kind" == "allObservationsStore" ]]; then
        stores+="${part}"$'\n'
      else
        metas+="${part}"$'\n'
      fi
    else
      die "dest not allowed in a partitioned manifest.tsv: ${dest}"
    fi
  done <<<"$dests"
  [[ $n_key -eq 1 ]] || die "a partitioned manifest.tsv needs exactly one encryption_key (found ${n_key})"
  [[ $n_meta -eq 1 ]] || die "a partitioned manifest.tsv needs exactly one metadata.json (found ${n_meta})"
  stores=$(printf '%s' "$stores" | sort)
  metas=$(printf '%s' "$metas" | sort)
  [[ "$stores" == "$metas" ]] || die "every partition needs both allObservationsStore.javabin and columnMeta.javabin"
  [[ -n "$stores" ]] || die "a partitioned manifest.tsv lists no partitions"
  distinct=$(printf '%s\n' "$stores" | wc -l | tr -d '[:space:]')
  [[ "$declared" =~ ^[0-9]+$ ]] || die "a partitioned manifest.tsv needs a numeric '# partitions=' header"
  [[ "$distinct" == "$declared" ]] || die "manifest.tsv declares ${declared} partitions but lists ${distinct}"
}

# Download one file into .incoming and verify its size and sha256 ('-' = not listed,
# flat manifests only).
fetch_verify() {
  local prefix=$1 incoming=$2 dest=$3 bytes=$4 sha=$5 actual
  mkdir -p "$(dirname "${incoming}/${dest}")"
  s3_copy "${prefix}${dest}" "${incoming}/${dest}"
  actual=$(wc -c <"${incoming}/${dest}" | tr -d '[:space:]')
  [[ "$actual" == "$bytes" ]] || die "size mismatch for ${dest}: manifest ${bytes}, downloaded ${actual}"
  if [[ "$sha" != "-" ]]; then
    actual=$(file_sha256 "${incoming}/${dest}")
    [[ "$actual" == "$sha" ]] || die "sha256 mismatch for ${dest}: manifest ${sha}, downloaded ${actual}"
  fi
  echo "Verified ${dest} (${bytes} bytes)"
}

# Download the variant's staged files and replace the dataset in /opt/local/hpds.
# Any failure before the swap exits non-zero with nothing moved. Sets HPDS_LAYOUT.
deploy_per_file_dataset() {
  local dataset_key=$1
  local prefix="s3://${stack_s3_bucket}/data/${dataset_key}/${STAGE_PREFIX}"
  local incoming="${HPDS_DIR:?}/.incoming"
  local previous="${HPDS_DIR}/.previous-phenotypic"
  local manifest="${DEPLOY_ROOT}/opt/picsure/manifest-${HPDS_VARIANT}.tsv"
  local line lineno=0 variant_seen="" header_seen=false layout="flat"
  local layout_lines=0 layout_seen="" partitions_lines=0 partitions_seen=""
  local removed_seen="" override_seen="" removed_lines=0 override_lines=0
  local dest bytes sha etag src
  local -a dests=() sizes=() shas=() pids=()
  local total=0 need avail_kb idx running seen seen_dests="" dup failed=0
  local parallel="${HPDS_DEPLOY_PARALLEL:-8}"

  echo "Per-file staged dataset found: ${prefix}manifest.tsv"
  mkdir -p "${DEPLOY_ROOT}/opt/picsure" "$HPDS_DIR"
  rm -rf "${incoming:?}"
  # The trap removes .incoming only; .previous-phenotypic is the old set and is never
  # removed here.
  trap 'rm -rf "${HPDS_DIR:?}/.incoming"' EXIT
  mkdir -p "$incoming"

  # Validated in .incoming; the kept copy is installed only after a successful swap.
  s3_copy "${prefix}manifest.tsv" "${incoming}/manifest.tsv"

  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$((lineno + 1))
    if [[ $lineno -eq 1 ]]; then
      [[ "$line" == "# bdc-hpds-deploy/1" ]] || die "manifest.tsv line 1 is not '# bdc-hpds-deploy/1'"
      continue
    fi
    if [[ "$line" == "#"* ]]; then
      if [[ "$header_seen" == "true" ]]; then
        case "$line" in
          "# layout="* | "# partitions="* | "# stigvars_removed="* | "# stigvars_override="*)
            die "manifest.tsv line ${lineno}: '${line%%=*}=' after the column header"
            ;;
        esac
      fi
      case "$line" in
        "# variant="*) variant_seen=${line#"# variant="} ;;
        "# layout="*)
          layout_lines=$((layout_lines + 1))
          layout_seen=${line#"# layout="}
          ;;
        "# partitions="*)
          partitions_lines=$((partitions_lines + 1))
          partitions_seen=${line#"# partitions="}
          ;;
        "# stigvars_removed="*)
          removed_lines=$((removed_lines + 1))
          removed_seen=${line#"# stigvars_removed="}
          ;;
        "# stigvars_override="*)
          override_lines=$((override_lines + 1))
          override_seen=${line#"# stigvars_override="}
          ;;
      esac
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
    seen_dests+="${dest}"$'\n'
    dests+=("$dest")
    sizes+=("$bytes")
    shas+=("$sha")
    total=$((total + bytes))
  done <"${incoming}/manifest.tsv"

  [[ "$header_seen" == "true" ]] || die "manifest.tsv has no header line"
  [[ ${#dests[@]} -gt 0 ]] || die "manifest.tsv lists no files"
  dup=$(printf '%s' "$seen_dests" | sort | uniq -d)
  dup=${dup%%$'\n'*}
  [[ -z "$dup" ]] || die "duplicate dest in manifest.tsv: ${dup}"

  [[ $layout_lines -le 1 ]] || die "manifest.tsv has more than one '# layout=' header"
  if [[ $layout_lines -eq 1 ]]; then
    [[ "$layout_seen" == "partitioned" ]] || die "unknown layout '${layout_seen}' in manifest.tsv"
    layout=partitioned
  fi

  # Open host, partitioned: exactly one '# stigvars_removed=true' and no override line (the
  # release removed the stigmatized variables), or exactly one '# stigvars_removed=false' with
  # exactly one '# stigvars_override=true' (not removed, dev only). Flat: no stigvars headers
  # or '# stigvars_removed=true' pass; 'false' needs the override.
  if [[ "$HPDS_VARIANT" == "open" ]]; then
    if [[ "$layout" == "partitioned" ]]; then
      if [[ $removed_lines -eq 1 && "$removed_seen" == "true" && $override_lines -eq 0 ]]; then
        :
      elif [[ $removed_lines -eq 1 && "$removed_seen" == "false" && $override_lines -eq 1 && "$override_seen" == "true" ]]; then
        :
      else
        die "a partitioned manifest.tsv for the open host needs exactly one '# stigvars_removed=true' and no '# stigvars_override', or exactly one '# stigvars_removed=false' and one '# stigvars_override=true'; refusing to serve it"
      fi
    elif [[ $removed_lines -gt 0 || $override_lines -gt 0 ]]; then
      if [[ $removed_lines -eq 1 && "$removed_seen" == "true" && $override_lines -eq 0 ]]; then
        :
      elif [[ $removed_lines -ne 1 || "$removed_seen" != "false" || $override_lines -ne 1 || "$override_seen" != "true" ]]; then
        die "a flat manifest.tsv for the open host needs no stigvars headers, '# stigvars_removed=true', or '# stigvars_removed=false' with '# stigvars_override=true'; refusing to serve it"
      fi
    fi
  fi

  if [[ "$layout" == "partitioned" ]]; then
    [[ $partitions_lines -eq 1 ]] || die "a partitioned manifest.tsv needs exactly one '# partitions=' header"
    check_partitioned_shape "$seen_dests" "$partitions_seen"
    for sha in "${shas[@]}"; do
      [[ "$sha" != "-" ]] || die "a partitioned manifest.tsv needs a sha256 for every file"
    done
  else
    [[ $partitions_lines -eq 0 ]] || die "manifest.tsv has '# partitions=' but no 'layout=partitioned'"
    for seen in allObservationsStore.javabin columnMeta.javabin; do
      grep -Fxq "$seen" <<<"$seen_dests" || die "manifest.tsv does not list ${seen}"
    done
    ! grep -Eq '^phenotypic(/|$)' <<<"$seen_dests" || die "a flat manifest.tsv must not list phenotypic/"
  fi

  # Per-host check of the validated dest list (one dest per line), defined by the script.
  variant_check_dests "$seen_dests"

  # The new set is written next to the live one (two sets are on disk until the swap
  # is done), so the free space must hold the whole new set.
  need=$((total + total / 10))
  avail_kb=$(df -Pk "$HPDS_DIR" | awk 'NR==2{print $4}')
  [[ "$avail_kb" =~ ^[0-9]+$ ]] || die "could not read free space of ${HPDS_DIR}"
  if ((avail_kb * 1024 < need)); then
    die "not enough free space in ${HPDS_DIR}: need ${need} bytes (total ${total} + 10%), have $((avail_kb * 1024))"
  fi

  # Bounded parallel download and verification of every file.
  [[ "$parallel" =~ ^[1-9][0-9]*$ ]] || parallel=8
  for idx in "${!dests[@]}"; do
    (fetch_verify "$prefix" "$incoming" "${dests[$idx]}" "${sizes[$idx]}" "${shas[$idx]}") &
    pids+=("$!")
    if [[ ${#pids[@]} -ge $parallel ]]; then
      for src in "${pids[@]}"; do wait "$src" || failed=1; done
      pids=()
      [[ $failed -eq 0 ]] || die "a download or verification failed"
    fi
  done
  if [[ ${#pids[@]} -gt 0 ]]; then
    for src in "${pids[@]}"; do wait "$src" || failed=1; done
  fi
  [[ $failed -eq 0 ]] || die "a download or verification failed"

  # Everything verified: stop the running HPDS so it never reads a half-replaced set.
  running=$(podman ps --format '{{.Names}}' || true)
  if grep -Fxq "$CONTAINER_NAME" <<<"$running"; then
    echo "Stopping running container ${CONTAINER_NAME} before replacing files"
    sudo systemctl stop "container-${CONTAINER_NAME}.service" 2>/dev/null || true
    podman stop "$CONTAINER_NAME" || true
    running=$(podman ps --format '{{.Names}}' || true)
    ! grep -Fxq "$CONTAINER_NAME" <<<"$running" || die "container ${CONTAINER_NAME} is still running; not replacing files"
  fi

  if [[ "$layout" == "partitioned" ]]; then
    # Keep the old set until the new one is in place and everything else is done.
    [[ ! -e "$previous" ]] || die "${previous} exists; not replacing files"
    if [[ -e "${HPDS_DIR}/phenotypic" ]]; then
      mv "${HPDS_DIR}/phenotypic" "$previous" || die "could not move the old phenotypic/ aside"
    fi
    if ! mv "${incoming}/phenotypic" "${HPDS_DIR}/phenotypic"; then
      if [[ -e "$previous" ]]; then
        mv "$previous" "${HPDS_DIR}/phenotypic" || echo "ERROR: could not restore the old phenotypic/ from ${previous}" >&2
      fi
      die "could not move the new phenotypic/ into place"
    fi
  fi
  for dest in "${dests[@]}"; do
    if [[ "$layout" == "partitioned" && "$dest" == phenotypic/* ]]; then
      continue
    fi
    mkdir -p "$(dirname "${HPDS_DIR}/${dest}")"
    mv -f "${incoming}/${dest}" "${HPDS_DIR}/${dest}"
  done
  if [[ "$layout" == "partitioned" ]]; then
    # No store of the previous (flat) layout stays at the top level.
    find "$HPDS_DIR" -maxdepth 1 \( -type f -o -type l \) -name '*.javabin' -exec rm -f {} +
  else
    rm -rf "${HPDS_DIR:?}/phenotypic"
  fi
  rm -f "${HPDS_DIR:?}/${LEGACY_TAR:?}"
  mv -f "${incoming}/manifest.tsv" "$manifest"
  trap - EXIT
  rm -rf "${incoming:?}"
  rm -rf "${previous:?}"
  HPDS_LAYOUT=$layout
  echo "Deployed ${#dests[@]} files (${layout} layout) for variant ${HPDS_VARIANT} into ${HPDS_DIR}"
}

# A flat deploy through the legacy tar: no partitioned set and no kept manifest remain.
finish_legacy_tar_deploy() {
  rm -rf "${HPDS_DIR:?}/phenotypic" "${HPDS_DIR:?}/.previous-phenotypic"
  rm -f "${DEPLOY_ROOT}/opt/picsure/manifest-${HPDS_VARIANT:?}.tsv"
  HPDS_LAYOUT=flat
}
# <<< end of the shared HPDS dataset block <<<

HPDS_VARIANT=auth
STAGE_PREFIX=javabins_rekeyed/
LEGACY_TAR=javabins_rekeyed.tar
CONTAINER_NAME="auth-hpds"
HPDS_REQUIRE_AUTH_FILTER=true

# Auth host: the manifest must not list the global partition (phenotypic/global/, any
# case). Authorization grants only fence-mapping keys and HPDS serves a partition
# directory by exact name, all or nothing, so a "global" partition here would expose
# every patient's global rows to whoever is granted "global". The open host serves it.
# Called by deploy_per_file_dataset on the dest list it validated (the very manifest it
# deploys), before any dataset file is downloaded or anything on the host is replaced.
# A grep error (status above 1) refuses too, so the check never fails open.
variant_check_dests() {
  local hit rc=0
  hit=$(grep -iE '^phenotypic/global(/|$)' <<<"$1") || rc=$?
  [[ $rc -eq 1 ]] && return 0
  [[ $rc -eq 0 ]] || die "could not check manifest.tsv for the global partition (grep status ${rc}); refusing to deploy"
  die "manifest.tsv for the auth host lists the global partition (${hit%%$'\n'*}); the auth host must never serve it, refusing to deploy"
}

# Dests of a manifest.tsv already on disk, one per line, split like the shared block does.
kept_manifest_dests() {
  local line dest rest
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" != '#'* && "$line" != $'dest\tbytes\tsha256\tetag\tsrc' ]] || continue
    IFS=$'\t' read -r dest rest <<<"$line"
    [[ -z "$dest" ]] || printf '%s\n' "$dest"
  done <"$1"
}

s3_copy "s3://${stack_s3_bucket}/${target_stack}/containers/pic-sure-hpds.tar.gz" "${DEPLOY_ROOT}/opt/picsure/pic-sure-hpds.tar.gz"
s3_copy "s3://${stack_s3_bucket}/configs/hpds/${target_stack}/auth-hpds.env" "${DEPLOY_ROOT}/opt/picsure/auth-hpds.env"

# A bad env file must never reach the point where the container is stopped for new data.
refuse_filter_not_true "${DEPLOY_ROOT}/opt/picsure/auth-hpds.env"

# A run that died mid-swap leaves state behind: the kept manifest may not match the
# disk, so the "dataset key unchanged" skip is ignored and the dataset is downloaded.
swap_state=0
recover_interrupted_swap || swap_state=$?
if [[ $swap_state -eq 10 && "$download_dataset" == "false" ]]; then
  echo "Interrupted run recovered: ignoring 'dataset key unchanged' and downloading the dataset"
  download_dataset=true
fi

if [[ "$download_dataset" == "true" ]]; then
  if staged_manifest_exists "$dataset_s3_object_key"; then
    deploy_per_file_dataset "$dataset_s3_object_key"
  else
    echo "No per-file manifest for ${dataset_s3_object_key}; using the legacy ${LEGACY_TAR}"
    s3_copy "s3://${stack_s3_bucket}/data/${dataset_s3_object_key}/${LEGACY_TAR}" "${HPDS_DIR}/${LEGACY_TAR}"
    cd "$HPDS_DIR" || exit 1
    tar -xvf "$LEGACY_TAR"
    cd ~ || exit 1
    finish_legacy_tar_deploy
  fi
else
  echo "Skipping javabins download — dataset_s3_object_key unchanged from previous run (${dataset_s3_object_key})"
  # The layout of what is on disk is the one of the kept manifest (none = flat).
  kept_manifest="${DEPLOY_ROOT}/opt/picsure/manifest-${HPDS_VARIANT}.tsv"
  if [[ -f "$kept_manifest" ]]; then
    # A global partition deployed before the guard existed is refused, not kept served.
    kept_dests=$(kept_manifest_dests "$kept_manifest") || die "could not read the kept ${kept_manifest} to check it for the global partition"
    variant_check_dests "$kept_dests"
    HPDS_LAYOUT=$(read_manifest_layout "$kept_manifest")
  fi
  if [[ "$HPDS_LAYOUT" == "partitioned" && ! -d "${HPDS_DIR}/phenotypic" ]]; then
    die "the kept manifest says partitioned but ${HPDS_DIR}/phenotypic is missing"
  fi
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

apply_env_settings "$HPDS_LAYOUT"

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
