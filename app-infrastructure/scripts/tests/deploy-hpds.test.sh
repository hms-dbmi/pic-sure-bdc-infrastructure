#!/bin/bash
# Tests for deploy/deploy-auth-hpds.sh and deploy/deploy-open-hpds.sh.
# Runs the real scripts against a fake root (HPDS_DEPLOY_ROOT) and a fake `aws`
# backed by a local directory tree; no network, no real /opt.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_DIR="$(cd "${SCRIPT_DIR}/../deploy" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK:?}"' EXIT

BUCKET=test-stack-bucket
STACK=blue
KEY=ds-new
GKEY=gen-1

pass=0
failed=0
check() { # check <description> <command...>
  local desc=$1
  shift
  if "$@"; then
    pass=$((pass + 1))
    echo "ok   - $desc"
  else
    failed=$((failed + 1))
    echo "FAIL - $desc"
  fi
}

# ---------------------------------------------------------------- fakebin
FAKEBIN="${WORK}/fakebin"
mkdir -p "$FAKEBIN"

cat >"${FAKEBIN}/aws" <<'FAKE'
#!/bin/bash
# fake aws: FAKE_S3 is a directory tree <bucket>/<key>
[[ "$1" == "--region" ]] && shift 2
echo "aws $*" >>"${FAKE_LOG}"
if [[ "$1 $2" == "s3 cp" ]]; then
  src=$3
  dst=$4
  recursive=false
  [[ "$*" == *--recursive* ]] && recursive=true
  local_src="${FAKE_S3}/${src#s3://}"
  if [[ "$recursive" == "false" && ! -f "$local_src" ]]; then
    echo "fake aws: no such key $src" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ "$recursive" == "true" ]]; then
    mkdir -p "$dst"
    [[ -d "$local_src" ]] && cp -R "$local_src/." "$dst/"
  else
    cp "$local_src" "$dst"
  fi
  exit 0
elif [[ "$1 $2" == "s3api list-objects-v2" ]]; then
  shift 2
  while [[ $# -gt 0 ]]; do
    case $1 in
      --bucket) bucket=$2 ;;
      --prefix) prefix=$2 ;;
    esac
    shift 2
  done
  keys=""
  while IFS= read -r f; do
    k=${f#"${FAKE_S3}/${bucket}/"}
    [[ "$k" == "$prefix"* ]] && keys+="${keys:+$'\t'}${k}"
  done < <(find "${FAKE_S3}/${bucket}" -type f 2>/dev/null | sort)
  echo "${keys:-None}"
  exit 0
fi
echo "fake aws: unsupported: $*" >&2
exit 2
FAKE

cat >"${FAKEBIN}/sudo" <<'FAKE'
#!/bin/bash
exec "$@"
FAKE

cat >"${FAKEBIN}/podman" <<'FAKE'
#!/bin/bash
# fake podman; FAKE_RUNNING lists running container names
echo "podman $*" >>"${FAKE_LOG}"
drop() {
  if [[ -f "${FAKE_RUNNING}" ]]; then
    grep -vFx "$1" "${FAKE_RUNNING}" >"${FAKE_RUNNING}.tmp" || true
    mv "${FAKE_RUNNING}.tmp" "${FAKE_RUNNING}"
  fi
}
case "$1" in
  load) echo "Loaded image: localhost/hpds:test" ;;
  ps) cat "${FAKE_RUNNING}" 2>/dev/null || true ;;
  stop | rm) drop "${*: -1}" ;;
  generate) echo "[Unit]" >"container-${4}.service" ;;
esac
exit 0
FAKE

cat >"${FAKEBIN}/systemctl" <<'FAKE'
#!/bin/bash
echo "systemctl $*" >>"${FAKE_LOG}"
svc=${*: -1}
svc=${svc#container-}
svc=${svc%.service}
case "$1" in
  stop)
    # record what the live columnMeta looked like when the container was stopped
    echo "STOP-saw: $(cat "${HPDS_DEPLOY_ROOT}/opt/local/hpds/columnMeta.javabin" 2>/dev/null)" >>"${FAKE_LOG}"
    if [[ -f "${FAKE_RUNNING}" ]]; then
      grep -vFx "$svc" "${FAKE_RUNNING}" >"${FAKE_RUNNING}.tmp" || true
      mv "${FAKE_RUNNING}.tmp" "${FAKE_RUNNING}"
    fi
    ;;
  start) echo "$svc" >>"${FAKE_RUNNING}" ;;
esac
exit 0
FAKE

cat >"${FAKEBIN}/restorecon" <<'FAKE'
#!/bin/bash
exit 0
FAKE

cat >"${FAKEBIN}/sleep" <<'FAKE'
#!/bin/bash
exit 0
FAKE

cat >"${FAKEBIN}/df" <<'FAKE'
#!/bin/bash
# fake df -Pk: FAKE_DF_AVAIL_KB available kilobytes
echo "Filesystem 1024-blocks Used Available Capacity Mounted on"
echo "fake 99999999 1 ${FAKE_DF_AVAIL_KB:-99999999} 1% /opt/local/hpds"
FAKE
chmod +x "${FAKEBIN}"/*

# ---------------------------------------------------------------- helpers
sha() { if command -v sha256sum >/dev/null; then sha256sum "$1" | awk '{print $1}'; else shasum -a 256 "$1" | awk '{print $1}'; fi; }
size() { wc -c <"$1" | tr -d ' '; }

new_env() { # new_env <name>: fresh root + s3 tree, sets CASE ROOT_DIR S3_DIR
  CASE="${WORK}/$1"
  ROOT_DIR="${CASE}/root"
  S3_DIR="${CASE}/s3"
  mkdir -p "${ROOT_DIR}/opt/picsure" "${ROOT_DIR}/opt/local/hpds/all" "${ROOT_DIR}/etc/systemd/system" "${S3_DIR}/${BUCKET}"
  : >"${CASE}/log"
  : >"${CASE}/running"
  echo "genomic-sentinel" >"${ROOT_DIR}/opt/local/hpds/all/chr1.dat"
  mkdir -p "${S3_DIR}/${BUCKET}/${STACK}/containers" "${S3_DIR}/${BUCKET}/configs/hpds/${STACK}"
  echo image >"${S3_DIR}/${BUCKET}/${STACK}/containers/pic-sure-hpds.tar.gz"
  echo "X=1" >"${S3_DIR}/${BUCKET}/configs/hpds/${STACK}/auth-hpds.env"
  echo "X=1" >"${S3_DIR}/${BUCKET}/configs/hpds/${STACK}/open-hpds.env"
  # live (old) data
  echo old-observations >"${ROOT_DIR}/opt/local/hpds/allObservationsStore.javabin"
  echo old-columnmeta >"${ROOT_DIR}/opt/local/hpds/columnMeta.javabin"
}

stage_dir() { # stage_dir <variant> <key>
  case $1 in
    auth) echo "${S3_DIR}/${BUCKET}/data/$2/javabins_rekeyed" ;;
    open) echo "${S3_DIR}/${BUCKET}/data/$2/destigmatized_javabins_rekeyed" ;;
  esac
}

# stage_variant <variant> <key> [variant-in-manifest]: staged files + manifest.tsv in the fake bucket.
# Files get content "<variant>:<dest>". Extra manifest rows may be given via EXTRA_ROWS (printf %b).
stage_variant() {
  local variant=$1 key=$2 header_variant=${3:-$1} dir f dest
  dir="$(stage_dir "$variant" "$key")/"
  mkdir -p "$dir"
  local -a dests=(allObservationsStore.javabin columnMeta.javabin encryption_key metadata.json)
  [[ $variant == open ]] && dests+=(conceptsToRemove.txt)
  {
    printf '# bdc-hpds-deploy/1\n# variant=%s\n# dataset_id=2026-11-04T0930Z\n# source=s3://example/datasets/2026-11-04T0930Z/\n# manifest_sha256=abc\n' "$header_variant"
    printf 'dest\tbytes\tsha256\tetag\tsrc\n'
    for dest in "${dests[@]}"; do
      f="${dir}${dest}"
      echo "${variant}:${dest}" >"$f"
      if [[ $dest == allObservationsStore.javabin ]]; then
        printf '%s\t%s\t-\t"etag"\t%s\n' "$dest" "$(size "$f")" "$dest"
      else
        printf '%s\t%s\t%s\t"etag"\t%s\n' "$dest" "$(size "$f")" "$(sha "$f")" "$dest"
      fi
    done
    if [[ -n ${EXTRA_ROWS:-} ]]; then printf '%b' "$EXTRA_ROWS"; fi
  } >"${dir}manifest.tsv"
}

stage_legacy_tar() { # stage_legacy_tar <name> <key>: tar holding old-style files
  local name=$1 key=$2 tmp="${CASE}/tarsrc"
  mkdir -p "$tmp" "${S3_DIR}/${BUCKET}/data/${key}"
  echo "legacy-observations" >"${tmp}/allObservationsStore.javabin"
  echo "legacy-columnmeta" >"${tmp}/columnMeta.javabin"
  tar -cf "${S3_DIR}/${BUCKET}/data/${key}/${name}" -C "$tmp" .
}

tree_state() { (cd "${ROOT_DIR}/opt/local/hpds" && find . | sort && find . -type f -exec cat {} + | cksum); }

run_deploy() { # run_deploy auth|open [key]; sets RC and OUT
  local variant=$1 key=${2:-$KEY} workdir="${CASE}/cwd"
  mkdir -p "$workdir"
  local -a common=(env PATH="${FAKEBIN}:${PATH}" HPDS_DEPLOY_ROOT="$ROOT_DIR" HPDS_AWS_BIN="${FAKEBIN}/aws"
    FAKE_S3="$S3_DIR" FAKE_LOG="${CASE}/log" FAKE_RUNNING="${CASE}/running" FAKE_DF_AVAIL_KB="${FAKE_DF_AVAIL_KB:-99999999}")
  if [[ $variant == auth ]]; then
    OUT=$(cd "$workdir" && "${common[@]}" bash "${DEPLOY_DIR}/deploy-auth-hpds.sh" --stack_s3_bucket "$BUCKET" \
      --dataset_s3_object_key "$key" --genomic_dataset_s3_object_key "$GKEY" --environment_name test \
      --target_stack "$STACK" --env_private_dns_name x.test 2>&1)
  else
    OUT=$(cd "$workdir" && "${common[@]}" bash "${DEPLOY_DIR}/deploy-open-hpds.sh" --stack_s3_bucket "$BUCKET" \
      --destigmatized_dataset_s3_object_key "$key" --target_stack "$STACK" 2>&1)
  fi
  RC=$?
}

# Auth runs skip the genomic download when the previous-execution file has the same genomic key.
skip_genomic() {
  cat >"${ROOT_DIR}/opt/picsure/deploy-script-last-execution-values.txt" <<EOT
export dataset_s3_object_key="old-key"
export genomic_dataset_s3_object_key="${GKEY}"
EOT
}

file_is() { [[ "$(cat "$1" 2>/dev/null)" == "$2" ]]; }
all_untouched() { file_is "${ROOT_DIR}/opt/local/hpds/all/chr1.dat" "genomic-sentinel" && [[ "$(find "${ROOT_DIR}/opt/local/hpds/all" -type f | wc -l | tr -d ' ')" == 1 ]]; }
no_incoming() { [[ ! -e "${ROOT_DIR}/opt/local/hpds/.incoming" ]]; }
out_has() { grep -q -- "$1" <<<"$OUT"; }
rc_zero_and_out_has() { [[ $RC -eq 0 ]] && out_has "$1"; }
rc_fail_and_unchanged() { [[ $RC -ne 0 && "$(tree_state)" == "$before" ]]; }
state_unchanged() { [[ "$(tree_state)" == "$before" ]]; }
not_in_log() { ! grep -q -- "$1" "${CASE}/log"; }
in_log() { grep -q -- "$1" "${CASE}/log"; }
rc_is_zero() { [[ $RC -eq 0 ]]; }
rc_is_nonzero() { [[ $RC -ne 0 ]]; }
absent() { [[ ! -e "$1" ]]; }

# ---------------------------------------------------------------- tests
echo "# per-file auth"
new_env auth-ok
stage_variant auth "$KEY"
echo "stale" >"${ROOT_DIR}/opt/local/hpds/javabins_rekeyed.tar"
skip_genomic
run_deploy auth
check "auth per-file exits 0" rc_is_zero
check "auth allObservationsStore.javabin deployed" file_is "${ROOT_DIR}/opt/local/hpds/allObservationsStore.javabin" "auth:allObservationsStore.javabin"
check "auth columnMeta.javabin deployed" file_is "${ROOT_DIR}/opt/local/hpds/columnMeta.javabin" "auth:columnMeta.javabin"
check "auth encryption_key deployed" file_is "${ROOT_DIR}/opt/local/hpds/encryption_key" "auth:encryption_key"
check "auth metadata.json deployed" file_is "${ROOT_DIR}/opt/local/hpds/metadata.json" "auth:metadata.json"
check "auth does not receive conceptsToRemove.txt" absent "${ROOT_DIR}/opt/local/hpds/conceptsToRemove.txt"
check "auth stale legacy tar removed" absent "${ROOT_DIR}/opt/local/hpds/javabins_rekeyed.tar"
check "auth no legacy tar downloaded" not_in_log 'javabins_rekeyed.tar'
check "auth .incoming removed" no_incoming
check "auth all/ untouched" all_untouched
check "auth container started" in_log 'systemctl start'

echo "# per-file open"
new_env open-ok
stage_variant open "$KEY"
echo "stale" >"${ROOT_DIR}/opt/local/hpds/destigmatized_javabins_rekeyed.tar"
run_deploy open
check "open per-file exits 0" rc_is_zero
check "open root columnMeta.javabin = open entry" file_is "${ROOT_DIR}/opt/local/hpds/columnMeta.javabin" "open:columnMeta.javabin"
check "open root columnMeta.javabin sha = open entry sha" [ "$(sha "${ROOT_DIR}/opt/local/hpds/columnMeta.javabin")" = "$(sha "$(stage_dir open "$KEY")/columnMeta.javabin")" ]
check "open conceptsToRemove.txt deployed" file_is "${ROOT_DIR}/opt/local/hpds/conceptsToRemove.txt" "open:conceptsToRemove.txt"
check "open allObservationsStore.javabin deployed" file_is "${ROOT_DIR}/opt/local/hpds/allObservationsStore.javabin" "open:allObservationsStore.javabin"
check "open stale legacy tar removed" absent "${ROOT_DIR}/opt/local/hpds/destigmatized_javabins_rekeyed.tar"
check "open .incoming removed" no_incoming
check "open all/ untouched" all_untouched
check "open container started" in_log 'systemctl start'

echo "# subdirectory dest"
new_env subdir
mkdir -p "$(stage_dir auth "$KEY")/static"
echo "meta2" >"$(stage_dir auth "$KEY")/static/extra.json"
EXTRA_ROWS="static/extra.json\t6\t$(sha "$(stage_dir auth "$KEY")/static/extra.json")\t\"e\"\tstatic/extra.json\n"
stage_variant auth "$KEY"
unset EXTRA_ROWS
skip_genomic
run_deploy auth
check "subdir dest: exits 0" rc_is_zero
check "subdir dest deployed" file_is "${ROOT_DIR}/opt/local/hpds/static/extra.json" "meta2"

echo "# running container is stopped before files move"
new_env stop
stage_variant auth "$KEY"
echo auth-hpds >"${CASE}/running"
skip_genomic
run_deploy auth
check "running container: exits 0" rc_is_zero
check "container was stopped while live columnMeta was still old" in_log 'STOP-saw: old-columnmeta'
check "new columnMeta in place afterwards" file_is "${ROOT_DIR}/opt/local/hpds/columnMeta.javabin" "auth:columnMeta.javabin"

echo "# wrong variant refusal"
new_env wrongvariant
stage_variant auth "$KEY" open # auth prefix, but the manifest says variant=open
skip_genomic
before=$(tree_state)
run_deploy auth
check "wrong variant: non-zero" rc_is_nonzero
check "wrong variant: message" out_has "variant 'open'"
check "wrong variant: hpds untouched" state_unchanged
new_env wrongvariant-open
stage_variant open "$KEY" auth
before=$(tree_state)
run_deploy open
check "open host refuses a variant=auth manifest" rc_fail_and_unchanged

echo "# sha256 mismatch refusal"
new_env shamismatch
stage_variant auth "$KEY"
# same byte count as the listed file, different content: only the sha256 check can catch it
orig_size=$(awk -F'\t' '$1=="columnMeta.javabin"{print $2}' "$(stage_dir auth "$KEY")/manifest.tsv")
head -c "$orig_size" </dev/zero | tr '\0' 'z' >"$(stage_dir auth "$KEY")/columnMeta.javabin"
skip_genomic
before=$(tree_state)
run_deploy auth
check "sha mismatch: non-zero" rc_is_nonzero
check "sha mismatch: message" out_has "sha256 mismatch for columnMeta.javabin"
check "sha mismatch: /opt/local/hpds untouched" state_unchanged
check "sha mismatch: container not started" not_in_log 'systemctl start'

echo "# byte count mismatch refusal"
new_env sizemismatch
stage_variant open "$KEY"
echo "longer content than listed" >"$(stage_dir open "$KEY")/allObservationsStore.javabin"
before=$(tree_state)
run_deploy open
check "size mismatch: non-zero" rc_is_nonzero
check "size mismatch: message" out_has "size mismatch for allObservationsStore.javabin"
check "size mismatch: /opt/local/hpds untouched" state_unchanged

echo "# unsafe dest refusal"
for bad in '../x' '/abs/x' 'a//b' 'a/../b' 'all/chr2.dat' 'a b' './x'; do
  new_env "unsafe-${bad//[^A-Za-z0-9]/_}"
  EXTRA_ROWS="${bad}\t3\t-\t\"e\"\tx\n"
  stage_variant auth "$KEY"
  unset EXTRA_ROWS
  skip_genomic
  before=$(tree_state)
  run_deploy auth
  check "unsafe dest '${bad}': non-zero" rc_is_nonzero
  check "unsafe dest '${bad}': message" out_has "unsafe dest"
  check "unsafe dest '${bad}': untouched" state_unchanged
  check "unsafe dest '${bad}': nothing written outside" absent "${ROOT_DIR}/opt/local/x"
done

echo "# free-space refusal"
new_env nospace
stage_variant auth "$KEY"
skip_genomic
before=$(tree_state)
FAKE_DF_AVAIL_KB=0 run_deploy auth
check "no space: non-zero" rc_is_nonzero
check "no space: message" out_has "not enough free space"
check "no space: untouched" state_unchanged
new_env space-ok
stage_variant auth "$KEY"
skip_genomic
FAKE_DF_AVAIL_KB=1 run_deploy auth
check "small dataset fits in 1 KiB free: exits 0" rc_is_zero

echo "# bad manifest"
new_env badheader
stage_variant auth "$KEY"
sed -i.bak '1s/.*/# bdc-hpds-deploy\/2/' "$(stage_dir auth "$KEY")/manifest.tsv"
skip_genomic
before=$(tree_state)
run_deploy auth
check "bad schema line: non-zero, untouched" rc_fail_and_unchanged

new_env missingfile
stage_variant auth "$KEY"
rm -f "${S3_DIR:?}/${BUCKET:?}/data/${KEY:?}/javabins_rekeyed/encryption_key"
skip_genomic
before=$(tree_state)
run_deploy auth
check "missing staged file: non-zero, untouched" rc_fail_and_unchanged

echo "# legacy tar path"
new_env legacy-auth
stage_legacy_tar javabins_rekeyed.tar "$KEY"
skip_genomic
run_deploy auth
check "auth legacy: exits 0" rc_is_zero
check "auth legacy: tar extracted" file_is "${ROOT_DIR}/opt/local/hpds/columnMeta.javabin" "legacy-columnmeta"
check "auth legacy: tar kept as before" test -f "${ROOT_DIR}/opt/local/hpds/javabins_rekeyed.tar"
check "auth legacy: used the legacy path" out_has "using the legacy javabins_rekeyed.tar"
check "auth legacy: all/ untouched" all_untouched
new_env legacy-open
stage_legacy_tar destigmatized_javabins_rekeyed.tar "$KEY"
run_deploy open
check "open legacy: exits 0" rc_is_zero
check "open legacy: tar extracted" file_is "${ROOT_DIR}/opt/local/hpds/columnMeta.javabin" "legacy-columnmeta"
check "open legacy: used the legacy path" out_has "using the legacy destigmatized_javabins_rekeyed.tar"
check "open legacy: all/ untouched" all_untouched

echo "# the other variant's manifest does not trigger the per-file path"
new_env other-variant
stage_variant open "$KEY" # only the open prefix is staged
stage_legacy_tar javabins_rekeyed.tar "$KEY"
skip_genomic
run_deploy auth
check "auth ignores open's manifest and uses the legacy tar" rc_zero_and_out_has "using the legacy javabins_rekeyed.tar"

echo "# skip-if-key-unchanged still honoured (auth)"
new_env skip
stage_variant auth "$KEY"
cat >"${ROOT_DIR}/opt/picsure/deploy-script-last-execution-values.txt" <<EOT
export dataset_s3_object_key="${KEY}"
export genomic_dataset_s3_object_key="${GKEY}"
EOT
run_deploy auth
check "unchanged key: exits 0" rc_is_zero
check "unchanged key: skipped" out_has "Skipping javabins download"
check "unchanged key: old columnMeta kept" file_is "${ROOT_DIR}/opt/local/hpds/columnMeta.javabin" "old-columnmeta"
check "unchanged key: no list call" not_in_log 'list-objects-v2'

echo "# genomic download is still the genomic step's job (auth, genomic key changed)"
new_env genomic
stage_variant auth "$KEY"
mkdir -p "${S3_DIR}/${BUCKET}/data/${GKEY}/all"
echo new-genomic >"${S3_DIR}/${BUCKET}/data/${GKEY}/all/chr1.dat"
run_deploy auth
check "genomic key changed: exits 0" rc_is_zero
check "genomic key changed: all/ updated by the genomic step only" file_is "${ROOT_DIR}/opt/local/hpds/all/chr1.dat" "new-genomic"
check "genomic key changed: per-file did not touch all/" not_in_log 'data/ds-new/javabins_rekeyed/all/'

echo
echo "passed: ${pass}, failed: ${failed}"
[[ $failed -eq 0 ]]
