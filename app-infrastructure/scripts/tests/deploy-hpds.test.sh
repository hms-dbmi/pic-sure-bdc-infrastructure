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
cat >"${FAKEBIN}/mv" <<'FAKE'
#!/bin/bash
# fake mv with failure injection (FAKE_MV_FAIL_SRC: fail when the source ends with it;
# FAKE_MV_DIE_AFTER: kill the calling script right after a move whose target ends with it).
args=()
for a in "$@"; do [[ $a == -* ]] || args+=("$a"); done
src=${args[0]:-}
dst=${args[1]:-}
if [[ -n ${FAKE_MV_FAIL_SRC:-} && $src == *"${FAKE_MV_FAIL_SRC}" ]]; then
  echo "fake mv: forced failure for ${src}" >&2
  exit 1
fi
/bin/mv "$@" || exit $?
if [[ -n ${FAKE_MV_DIE_AFTER:-} && $dst == *"${FAKE_MV_DIE_AFTER}" ]]; then
  kill -9 "$PPID"
fi
exit 0
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
    FAKE_S3="$S3_DIR" FAKE_LOG="${CASE}/log" FAKE_RUNNING="${CASE}/running" FAKE_DF_AVAIL_KB="${FAKE_DF_AVAIL_KB:-99999999}"
    FAKE_MV_FAIL_SRC="${FAKE_MV_FAIL_SRC:-}" FAKE_MV_DIE_AFTER="${FAKE_MV_DIE_AFTER:-}" HPDS_DEPLOY_PARALLEL="${HPDS_DEPLOY_PARALLEL:-3}")
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

# ---------------------------------------------------------------- partitioned helpers
put_env() { # put_env <variant> <printf %b text>: the stack env file as stored in S3
  printf '%b' "$2" >"${S3_DIR}/${BUCKET}/configs/hpds/${STACK}/$1-hpds.env"
}
env_file_of() { echo "${ROOT_DIR}/opt/picsure/$1-hpds.env"; }
env_has() { grep -Fxq -- "$2" "$(env_file_of "$1")"; }
env_lacks() { ! grep -Fq -- "$2" "$(env_file_of "$1")"; }
kept_of() { echo "${ROOT_DIR}/opt/picsure/manifest-$1.tsv"; }
part_path() { echo "${ROOT_DIR}/opt/local/hpds/phenotypic/$1/$2"; }
no_toplevel_javabin() { [[ -z "$(find "${ROOT_DIR}/opt/local/hpds" -maxdepth 1 -name '*.javabin')" ]]; }
part_count() { find "${ROOT_DIR}/opt/local/hpds/phenotypic" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '; }
no_leftovers() { [[ ! -e "${ROOT_DIR}/opt/local/hpds/.incoming" && ! -e "${ROOT_DIR}/opt/local/hpds/.previous-phenotypic" ]]; }
same_file() { cmp -s "$1" "$2"; }

snap() { # remember the host state (data dir + kept manifests) before a run that must change nothing
  before=$(tree_state)
  kept_before=$(cat "$(kept_of auth)" "$(kept_of open)" 2>/dev/null || true)
}
unchanged_all() { [[ "$(tree_state)" == "$before" && "$(cat "$(kept_of auth)" "$(kept_of open)" 2>/dev/null || true)" == "$kept_before" ]]; }
refused() { [[ $RC -ne 0 ]] && unchanged_all && out_has "$1"; }

# stage_partitioned <variant> <key>: a layout=partitioned dataset in the fake bucket.
# Knobs (env): PART_NAMES, PART_TAG (content tag), PART_DECLARED (number or "none"),
# PART_LAYOUT_LINE (default "# layout=partitioned", empty = omit), PART_EXTRA_HEADERS,
# PART_STIG_HEADERS (open only, printf %b; default: removed=false + override=true),
# PART_OPEN_META_SRC (partition names, space separated: their columnMeta rows get src open/partitions/<p>/columnMeta.javabin),
# PART_EXTRA_ROWS (printf %b rows), PART_SKIP_ROW (dest left out of the manifest),
# PART_DASH_SHA (dest whose sha256 is written as "-").
stage_partitioned() {
  local variant=$1 key=$2 dir dest f part tag=${PART_TAG:-p1} declared src
  local -a names=() dests=()
  read -ra names <<<"${PART_NAMES-phs000000.c1 phs999999.c2 phs123456.c1}"
  declared=${PART_DECLARED:-${#names[@]}}
  dir="$(stage_dir "$variant" "$key")/"
  mkdir -p "$dir"
  dests=(encryption_key metadata.json)
  for part in ${names[@]+"${names[@]}"}; do
    dests+=("phenotypic/${part}/allObservationsStore.javabin" "phenotypic/${part}/columnMeta.javabin")
  done
  {
    printf '# bdc-hpds-deploy/1\n# variant=%s\n' "$variant"
    if [[ -n ${PART_LAYOUT_LINE-"# layout=partitioned"} ]]; then printf '%s\n' "${PART_LAYOUT_LINE-"# layout=partitioned"}"; fi
    if [[ $declared != none ]]; then printf '# partitions=%s\n' "$declared"; fi
    printf '# dataset_id=2026-11-17T0930Z\n# source=s3://example/pheno-partitioned/datasets/2026-11-17T0930Z/\n# manifest_sha256=abc\n'
    if [[ $variant == open ]]; then printf '%b' "${PART_STIG_HEADERS-# stigvars_removed=false\n# stigvars_override=true\n}"; fi
    if [[ -n ${PART_EXTRA_HEADERS:-} ]]; then printf '%b' "$PART_EXTRA_HEADERS"; fi
    printf 'dest\tbytes\tsha256\tetag\tsrc\n'
    for dest in "${dests[@]}"; do
      f="${dir}${dest}"
      mkdir -p "$(dirname "$f")"
      echo "${variant}:${tag}:${dest}" >"$f"
      [[ ${PART_SKIP_ROW:-} != "$dest" ]] || continue
      if [[ ${PART_DASH_SHA:-} == "$dest" ]]; then
        printf '%s\t%s\t-\t"etag"\t%s\n' "$dest" "$(size "$f")" "$dest"
      else
        src=$dest
        if [[ $dest == phenotypic/*/columnMeta.javabin ]]; then
          part=${dest#phenotypic/}
          part=${part%%/*}
          [[ " ${PART_OPEN_META_SRC:-} " != *" ${part} "* ]] || src="open/partitions/${part}/columnMeta.javabin"
        fi
        printf '%s\t%s\t%s\t"etag"\t%s\n' "$dest" "$(size "$f")" "$(sha "$f")" "$src"
      fi
    done
    if [[ -n ${PART_EXTRA_ROWS:-} ]]; then printf '%b' "$PART_EXTRA_ROWS"; fi
  } >"${dir}manifest.tsv"
}

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

# ================================================================ partitioned layout (contract v2)
P1=phs000000.c1
P2=phs999999.c2
P3=phs123456.c1
ENV_TEMPLATE='JAVA_OPTS=-Xmx1g\nHPDS_DATA_DIRECTORY=/opt/local/hpds/\nX=1\n'

echo "# the two host scripts carry an identical shared block"
shared_block() { sed -n '/^# >>> shared HPDS dataset block/,/^# <<< end of the shared HPDS dataset block/p' "$1"; }
check "shared block present" [ -n "$(shared_block "${DEPLOY_DIR}/deploy-auth-hpds.sh")" ]
check "shared block identical in auth and open" [ "$(shared_block "${DEPLOY_DIR}/deploy-auth-hpds.sh")" = "$(shared_block "${DEPLOY_DIR}/deploy-open-hpds.sh")" ]

echo "# partitioned auth deploy (flat -> partitioned)"
new_env p-auth
put_env auth "$ENV_TEMPLATE"
echo "old-kept" >"$(kept_of auth)"
echo "stale" >"${ROOT_DIR}/opt/local/hpds/javabins_rekeyed.tar"
echo "other" >"${ROOT_DIR}/opt/local/hpds/extra.javabin"
echo old-key >"${ROOT_DIR}/opt/local/hpds/encryption_key"
stage_partitioned auth "$KEY"
skip_genomic
run_deploy auth
check "partitioned auth: exits 0" rc_is_zero
check "partitioned auth: layout reported" out_has "(partitioned layout)"
check "partitioned auth: store of $P1" file_is "$(part_path $P1 allObservationsStore.javabin)" "auth:p1:phenotypic/$P1/allObservationsStore.javabin"
check "partitioned auth: columnMeta of $P2" file_is "$(part_path $P2 columnMeta.javabin)" "auth:p1:phenotypic/$P2/columnMeta.javabin"
check "partitioned auth: store of $P3" file_is "$(part_path $P3 allObservationsStore.javabin)" "auth:p1:phenotypic/$P3/allObservationsStore.javabin"
check "partitioned auth: 3 partition directories" [ "$(part_count)" = 3 ]
check "partitioned auth: encryption_key replaced" file_is "${ROOT_DIR}/opt/local/hpds/encryption_key" "auth:p1:encryption_key"
check "partitioned auth: metadata.json deployed" file_is "${ROOT_DIR}/opt/local/hpds/metadata.json" "auth:p1:metadata.json"
check "partitioned auth: no top-level javabin left" no_toplevel_javabin
check "partitioned auth: stale legacy tar removed" absent "${ROOT_DIR}/opt/local/hpds/javabins_rekeyed.tar"
check "partitioned auth: no .incoming or .previous-phenotypic" no_leftovers
check "partitioned auth: all/ untouched" all_untouched
check "partitioned auth: kept manifest installed (replaced the old one)" same_file "$(kept_of auth)" "$(stage_dir auth "$KEY")/manifest.tsv"
check "partitioned auth: filter true appended to JAVA_OPTS" env_has auth "JAVA_OPTS=-Xmx1g -Dhpds.requireAuthorizationFilter=true"
check "partitioned auth: HPDS_DATA_DIRECTORY replaced" env_has auth "HPDS_DATA_DIRECTORY=/opt/local/hpds/phenotypic/"
check "partitioned auth: other env lines kept" env_has auth "X=1"
check "partitioned auth: container started" in_log 'systemctl start'
check "partitioned auth: data dir not set twice" [ "$(grep -c '^HPDS_DATA_DIRECTORY=' "$(env_file_of auth)")" = 1 ]

echo "# partitioned -> partitioned drops a stale partition"
stage_partitioned auth ds-two
PART_NAMES="$P1 $P2" PART_TAG=p2 stage_partitioned auth ds-two
run_deploy auth ds-two
check "repartition: exits 0" rc_is_zero
check "repartition: stale partition gone" absent "${ROOT_DIR}/opt/local/hpds/phenotypic/${P3}"
check "repartition: 2 partitions" [ "$(part_count)" = 2 ]
check "repartition: new content" file_is "$(part_path $P1 columnMeta.javabin)" "auth:p2:phenotypic/$P1/columnMeta.javabin"
check "repartition: no leftovers" no_leftovers
check "repartition: kept manifest follows" same_file "$(kept_of auth)" "$(stage_dir auth ds-two)/manifest.tsv"

echo "# partitioned -> flat (rollback): phenotypic/ removed, top-level files back"
stage_variant auth ds-flat
run_deploy auth ds-flat
check "to flat: exits 0" rc_is_zero
check "to flat: phenotypic/ removed" absent "${ROOT_DIR}/opt/local/hpds/phenotypic"
check "to flat: top-level store restored" file_is "${ROOT_DIR}/opt/local/hpds/allObservationsStore.javabin" "auth:allObservationsStore.javabin"
check "to flat: top-level columnMeta restored" file_is "${ROOT_DIR}/opt/local/hpds/columnMeta.javabin" "auth:columnMeta.javabin"
check "to flat: no leftovers" no_leftovers
check "to flat: kept manifest is the flat one" same_file "$(kept_of auth)" "$(stage_dir auth ds-flat)/manifest.tsv"
check "to flat: filter true still appended" env_has auth "JAVA_OPTS=-Xmx1g -Dhpds.requireAuthorizationFilter=true"
check "to flat: data directory left as the stack env has it" env_has auth "HPDS_DATA_DIRECTORY=/opt/local/hpds/"
check "to flat: all/ untouched" all_untouched

echo "# flat -> partitioned: top-level javabins removed again"
run_deploy auth "$KEY"
check "back to partitioned: exits 0" rc_is_zero
check "back to partitioned: no top-level javabin" no_toplevel_javabin
check "back to partitioned: partitions present" [ "$(part_count)" = 3 ]

echo "# partitioned open deploy"
new_env p-open
put_env open "$ENV_TEMPLATE"
stage_partitioned open "$KEY"
run_deploy open
check "partitioned open: exits 0" rc_is_zero
check "partitioned open: store" file_is "$(part_path $P2 allObservationsStore.javabin)" "open:p1:phenotypic/$P2/allObservationsStore.javabin"
check "partitioned open: columnMeta" file_is "$(part_path $P2 columnMeta.javabin)" "open:p1:phenotypic/$P2/columnMeta.javabin"
check "partitioned open: no top-level javabin" no_toplevel_javabin
check "partitioned open: no conceptsToRemove.txt" absent "${ROOT_DIR}/opt/local/hpds/conceptsToRemove.txt"
check "partitioned open: filter false appended" env_has open "JAVA_OPTS=-Xmx1g -Dhpds.requireAuthorizationFilter=false"
check "partitioned open: HPDS_DATA_DIRECTORY set" env_has open "HPDS_DATA_DIRECTORY=/opt/local/hpds/phenotypic/"
check "partitioned open: kept manifest installed" same_file "$(kept_of open)" "$(stage_dir open "$KEY")/manifest.tsv"
check "partitioned open: all/ untouched" all_untouched
check "partitioned open: container started" in_log 'systemctl start'

echo "# open: flat deploys get the filter false, env without JAVA_OPTS gets the line"
new_env o-flat
put_env open 'X=1\n'
stage_variant open "$KEY"
run_deploy open
check "flat open: exits 0" rc_is_zero
check "flat open: JAVA_OPTS line added" env_has open "JAVA_OPTS=-Dhpds.requireAuthorizationFilter=false"
check "flat open: no HPDS_DATA_DIRECTORY added" env_lacks open "HPDS_DATA_DIRECTORY"
check "flat open: filter true in the env file does not stop the open host" rc_is_zero
new_env o-true
put_env open 'JAVA_OPTS="-Xmx1g -Dhpds.requireAuthorizationFilter=true"\n'
stage_variant open "$KEY"
run_deploy open
check "open: a quoted JAVA_OPTS keeps its quotes, last property wins" env_has open 'JAVA_OPTS="-Xmx1g -Dhpds.requireAuthorizationFilter=true -Dhpds.requireAuthorizationFilter=false"'

echo "# auth: partitioned env without JAVA_OPTS / HPDS_DATA_DIRECTORY gets both lines"
new_env a-add
put_env auth 'X=1\n'
stage_partitioned auth "$KEY"
skip_genomic
run_deploy auth
check "auth add: exits 0" rc_is_zero
check "auth add: JAVA_OPTS line added" env_has auth "JAVA_OPTS=-Dhpds.requireAuthorizationFilter=true"
check "auth add: HPDS_DATA_DIRECTORY appended" env_has auth "HPDS_DATA_DIRECTORY=/opt/local/hpds/phenotypic/"

echo "# auth refuses an env file with the filter off, before any dataset step"
n=0
for bad in \
  'JAVA_OPTS=-Xmx1g -Dhpds.requireAuthorizationFilter=false\n' \
  'JAVA_OPTS=-Dhpds.requireAuthorizationFilter=true -Dhpds.requireAuthorizationFilter=false\n' \
  'HPDS_REQUIREAUTHORIZATIONFILTER=false\n' \
  'hpds.requireAuthorizationFilter: FALSE\n' \
  'JAVA_OPTS="-Xmx1g -DrequireAuthorizationFilter=no"\n' \
  'JAVA_OPTS=-Dhpds.requireAuthorizationFilter=TRUE\n' \
  'JAVA_OPTS=-Dhpds.requireAuthorizationFilter=\n' \
  '# HPDS_requireAuthorizationFilter\n' \
  'SPRING_APPLICATION_JSON={"hpds.requireAuthorizationFilter":false,"x":"-Dhpds.requireAuthorizationFilter=true"}\n' \
  'JAVA_OPTS=-Dhpds.requireAuthorizationFilter=true -Dhpds.REQUIREAUTHORIZATIONFILTER=false\n' \
  'SPRING_APPLICATION_JSON={"hpds.requireAuthorizationFilter":false}\n' \
  'SPRING_APPLICATION_JSON={"hpds.requireAuthorizationFilter":"false","y":1}\n' \
  'A=1\nHPDS_REQUIREAUTHORIZATIONFILTER=true\nHPDS_REQUIREAUTHORIZATIONFILTER=false\n'; do
  n=$((n + 1))
  new_env "a-filter-$n"
  put_env auth "$bad"
  stage_partitioned auth "$KEY"
  skip_genomic
  echo auth-hpds >"${CASE}/running"
  snap
  run_deploy auth
  check "filter refusal $n: non-zero" rc_is_nonzero
  check "filter refusal $n: message" out_has "requireAuthorizationFilter"
  check "filter refusal $n: host untouched" unchanged_all
  check "filter refusal $n: refused before any dataset step" not_in_log 'list-objects-v2'
  check "filter refusal $n: container not stopped" not_in_log 'systemctl stop'
  check "filter refusal $n: container not created" not_in_log 'podman create'
done
new_env a-filter-flat
put_env auth 'JAVA_OPTS=-Dhpds.requireAuthorizationFilter=false\n'
stage_variant auth "$KEY"
skip_genomic
snap
run_deploy auth
check "filter refusal on a flat dataset too" refused "requireAuthorizationFilter"
new_env a-filter-true
put_env auth 'JAVA_OPTS=-Xmx1g -Dhpds.requireAuthorizationFilter=true\nHPDS_REQUIREAUTHORIZATIONFILTER=true\n'
stage_partitioned auth "$KEY"
skip_genomic
run_deploy auth
check "env that already sets the filter true is accepted" rc_is_zero
check "env with the filter true: still appended" env_has auth "JAVA_OPTS=-Xmx1g -Dhpds.requireAuthorizationFilter=true -Dhpds.requireAuthorizationFilter=true"
new_env a-filter-json
put_env auth 'SPRING_APPLICATION_JSON={"hpds.requireAuthorizationFilter":true,"x":"y"}\nJAVA_OPTS=-Xmx1g\n'
stage_partitioned auth "$KEY"
skip_genomic
run_deploy auth
check "a JSON key with the value true is accepted" rc_is_zero
new_env a-filter-json-quoted
put_env auth 'SPRING_APPLICATION_JSON={"hpds.requireAuthorizationFilter":"true"}\n'
stage_partitioned auth "$KEY"
skip_genomic
run_deploy auth
check "a JSON key with the string true is accepted" rc_is_zero

echo "# the kept manifest is installed only after a successful swap"
new_env kept
echo "old-kept" >"$(kept_of auth)"
stage_partitioned auth "$KEY"
skip_genomic
orig_size=$(size "$(stage_dir auth "$KEY")/phenotypic/$P1/columnMeta.javabin")
head -c "$orig_size" </dev/zero | tr '\0' 'z' >"$(stage_dir auth "$KEY")/phenotypic/$P1/columnMeta.javabin"
snap
run_deploy auth
check "bad sha (partitioned): non-zero" rc_is_nonzero
check "bad sha (partitioned): message" out_has "sha256 mismatch for phenotypic/$P1/columnMeta.javabin"
check "bad sha (partitioned): host untouched" unchanged_all
check "bad sha (partitioned): old kept manifest still there" file_is "$(kept_of auth)" "old-kept"
check "bad sha (partitioned): container not started" not_in_log 'systemctl start'
new_env kept-store
stage_partitioned auth "$KEY"
skip_genomic
echo "longer store content than listed" >"$(stage_dir auth "$KEY")/phenotypic/$P2/allObservationsStore.javabin"
snap
run_deploy auth
check "bad size of a store: refused, untouched" refused "size mismatch for phenotypic/$P2/allObservationsStore.javabin"
new_env kept-missing
stage_partitioned auth "$KEY"
skip_genomic
rm -f "${S3_DIR:?}/${BUCKET:?}/data/${KEY:?}/javabins_rekeyed/phenotypic/${P3}/columnMeta.javabin"
snap
HPDS_DEPLOY_PARALLEL=2 run_deploy auth
check "missing staged file in a parallel batch: non-zero, untouched" refused "ERROR"
new_env kept-legacy
echo "old-kept" >"$(kept_of auth)"
stage_legacy_tar javabins_rekeyed.tar "$KEY"
skip_genomic
run_deploy auth
check "legacy tar deletes the kept manifest" absent "$(kept_of auth)"

echo "# a legacy tar deploy removes the partitioned set"
new_env legacy-after-part
stage_partitioned auth ds-part
stage_legacy_tar javabins_rekeyed.tar ds-leg
skip_genomic
run_deploy auth ds-part
check "legacy-after-part: partitioned first" [ "$(part_count)" = 3 ]
run_deploy auth ds-leg
check "legacy-after-part: exits 0" rc_is_zero
check "legacy-after-part: phenotypic/ removed" absent "${ROOT_DIR}/opt/local/hpds/phenotypic"
check "legacy-after-part: tar files in place" file_is "${ROOT_DIR}/opt/local/hpds/columnMeta.javabin" "legacy-columnmeta"
check "legacy-after-part: kept manifest removed" absent "$(kept_of auth)"
check "legacy-after-part: no data dir setting" env_lacks auth "HPDS_DATA_DIRECTORY=/opt/local/hpds/phenotypic/"

echo "# key unchanged: the layout comes from the kept manifest"
new_env skip-part
put_env auth "$ENV_TEMPLATE"
stage_partitioned auth "$KEY"
skip_genomic
run_deploy auth
check "skip setup: partitioned deploy" rc_is_zero
: >"${CASE}/log"
snap
run_deploy auth
check "skip (partitioned): exits 0" rc_is_zero
check "skip (partitioned): download skipped" out_has "Skipping javabins download"
check "skip (partitioned): no list call" not_in_log 'list-objects-v2'
check "skip (partitioned): data directory set from the kept manifest" env_has auth "HPDS_DATA_DIRECTORY=/opt/local/hpds/phenotypic/"
check "skip (partitioned): filter true" env_has auth "JAVA_OPTS=-Xmx1g -Dhpds.requireAuthorizationFilter=true"
check "skip (partitioned): data untouched" unchanged_all
rm -rf "${ROOT_DIR:?}/opt/local/hpds/phenotypic"
run_deploy auth
check "skip (partitioned, phenotypic/ missing): refused" rc_is_nonzero
new_env skip-flat
put_env auth "$ENV_TEMPLATE"
stage_variant auth "$KEY"
skip_genomic
run_deploy auth
run_deploy auth
check "skip (flat kept manifest): exits 0, skipped" rc_zero_and_out_has "Skipping javabins download"
check "skip (flat kept manifest): data directory as in the stack env" env_has auth "HPDS_DATA_DIRECTORY=/opt/local/hpds/"
check "skip (flat kept manifest): filter true" env_has auth "JAVA_OPTS=-Xmx1g -Dhpds.requireAuthorizationFilter=true"
new_env skip-none
put_env auth "$ENV_TEMPLATE"
cat >"${ROOT_DIR}/opt/picsure/deploy-script-last-execution-values.txt" <<EOT
export dataset_s3_object_key="${KEY}"
export genomic_dataset_s3_object_key="${GKEY}"
EOT
run_deploy auth
check "skip (no kept manifest = flat): no data directory change" env_has auth "HPDS_DATA_DIRECTORY=/opt/local/hpds/"
new_env skip-badlayout
echo "# bdc-hpds-deploy/1" >"$(kept_of auth)"
echo "# layout=flat" >>"$(kept_of auth)"
cat >"${ROOT_DIR}/opt/picsure/deploy-script-last-execution-values.txt" <<EOT
export dataset_s3_object_key="${KEY}"
export genomic_dataset_s3_object_key="${GKEY}"
EOT
run_deploy auth
check "skip (kept manifest with an unknown layout): refused" rc_is_nonzero

echo "# crash safety of the swap"
mk_two() { # two partitioned datasets (tags p1 / p2) on an auth host with p1 deployed
  new_env "$1"
  put_env auth "$ENV_TEMPLATE"
  PART_TAG=p1 stage_partitioned auth ds-1
  PART_TAG=p2 stage_partitioned auth ds-2
  skip_genomic
  run_deploy auth ds-1
}
mk_two crash-a
check "crash setup: ds-1 deployed" file_is "$(part_path $P1 columnMeta.javabin)" "auth:p1:phenotypic/$P1/columnMeta.javabin"
FAKE_MV_DIE_AFTER=/.previous-phenotypic run_deploy auth ds-2
check "died after setting the old set aside: script was killed" [ "$RC" -ne 0 ]
check "died after the first rename: no phenotypic/" absent "${ROOT_DIR}/opt/local/hpds/phenotypic"
check "died after the first rename: old set kept in .previous-phenotypic" file_is "${ROOT_DIR}/opt/local/hpds/.previous-phenotypic/$P1/columnMeta.javabin" "auth:p1:phenotypic/$P1/columnMeta.javabin"
check "died after the first rename: kept manifest still ds-1" same_file "$(kept_of auth)" "$(stage_dir auth ds-1)/manifest.tsv"
run_deploy auth ds-1
check "recovery (key unchanged, would have skipped): exits 0" rc_is_zero
check "recovery: old set renamed back" out_has "restoring"
check "recovery: the skip is ignored, full download" out_has "ignoring 'dataset key unchanged'"
check "recovery: ds-1 set in place" file_is "$(part_path $P1 columnMeta.javabin)" "auth:p1:phenotypic/$P1/columnMeta.javabin"
check "recovery: no leftovers" no_leftovers
check "recovery: kept manifest matches the disk" same_file "$(kept_of auth)" "$(stage_dir auth ds-1)/manifest.tsv"
run_deploy auth ds-2
check "after recovery the next deploy completes" file_is "$(part_path $P1 columnMeta.javabin)" "auth:p2:phenotypic/$P1/columnMeta.javabin"

mk_two crash-b
FAKE_MV_DIE_AFTER=/phenotypic run_deploy auth ds-2
check "died after the second rename: script was killed" [ "$RC" -ne 0 ]
check "died after the second rename: new set in place, old set kept" [ -d "${ROOT_DIR}/opt/local/hpds/.previous-phenotypic" ]
run_deploy auth ds-1
check "recovery from a late death: exits 0" rc_is_zero
check "recovery from a late death: leftover removed, skip ignored" out_has "ignoring 'dataset key unchanged'"
check "recovery from a late death: ds-1 fully in place" file_is "${ROOT_DIR}/opt/local/hpds/encryption_key" "auth:p1:encryption_key"
check "recovery from a late death: no leftovers" no_leftovers

mk_two crash-c
FAKE_MV_FAIL_SRC=/.incoming/phenotypic run_deploy auth ds-2
check "second rename fails: non-zero" rc_is_nonzero
check "second rename fails: old set renamed back" file_is "$(part_path $P1 columnMeta.javabin)" "auth:p1:phenotypic/$P1/columnMeta.javabin"
check "second rename fails: no leftovers (.incoming removed by the trap)" no_leftovers
check "second rename fails: kept manifest still ds-1" same_file "$(kept_of auth)" "$(stage_dir auth ds-1)/manifest.tsv"

mk_two crash-d
FAKE_MV_FAIL_SRC=/.incoming/encryption_key run_deploy auth ds-2
check "failure after both renames: non-zero" rc_is_nonzero
check "the EXIT trap removed .incoming" absent "${ROOT_DIR}/opt/local/hpds/.incoming"
check "the EXIT trap kept .previous-phenotypic" [ -d "${ROOT_DIR}/opt/local/hpds/.previous-phenotypic" ]
run_deploy auth ds-2
check "next run removes the leftover and completes" rc_zero_and_out_has "Removing leftover"
check "next run: ds-2 in place, no leftovers" no_leftovers
check "next run: ds-2 content" file_is "$(part_path $P1 columnMeta.javabin)" "auth:p2:phenotypic/$P1/columnMeta.javabin"

echo "# dirty-run recovery ignores 'dataset key unchanged' (auth)"
mk_two dirty-incoming
mkdir -p "${ROOT_DIR}/opt/local/hpds/.incoming/junk"
: >"${CASE}/log"
run_deploy auth ds-1
check "leftover .incoming: exits 0" rc_is_zero
check "leftover .incoming: full download" in_log 'list-objects-v2'
check "leftover .incoming: skip ignored" out_has "ignoring 'dataset key unchanged'"
check "leftover .incoming: removed" no_leftovers
mk_two dirty-previous
mkdir -p "${ROOT_DIR}/opt/local/hpds/.previous-phenotypic/old.c1"
: >"${CASE}/log"
run_deploy auth ds-1
check "leftover .previous-phenotypic (phenotypic/ present): full download" out_has "ignoring 'dataset key unchanged'"
check "leftover .previous-phenotypic: removed" no_leftovers
mk_two clean-run
: >"${CASE}/log"
run_deploy auth ds-1
check "clean run with an unchanged key still skips" out_has "Skipping javabins download"
new_env dirty-open
put_env open "$ENV_TEMPLATE"
stage_partitioned open "$KEY"
mkdir -p "${ROOT_DIR}/opt/local/hpds/.incoming/junk" "${ROOT_DIR}/opt/local/hpds/.previous-phenotypic"
run_deploy open
check "open: leftovers removed, deploy completes" rc_is_zero
check "open: no leftovers" no_leftovers

echo "# free-space refusal (partitioned)"
new_env p-nospace
stage_partitioned auth "$KEY"
skip_genomic
snap
FAKE_DF_AVAIL_KB=0 run_deploy auth
check "partitioned, no space: refused, untouched" refused "not enough free space"
new_env p-space
stage_partitioned open "$KEY"
FAKE_DF_AVAIL_KB=1 run_deploy open
check "partitioned, small set fits in 1 KiB free" rc_is_zero

echo "# bad partition names and manifest shapes (partitioned)"
for bad in '.hidden' '_under' '-lead' "$(printf 'a%.0s' {1..129})"; do
  new_env "badname-${#bad}-${bad:0:3}"
  PART_NAMES="$P1 $bad" PART_DECLARED=2 stage_partitioned auth "$KEY"
  skip_genomic
  snap
  run_deploy auth
  check "bad partition name '${bad:0:12}' (${#bad} chars): refused" refused "bad partition name"
done
new_env okname
PART_NAMES="A1 phs000000.c1 a.b_c-d" PART_DECLARED=3 stage_partitioned auth "$KEY"
skip_genomic
run_deploy auth
check "allowed name characters deploy" rc_is_zero

shape_case() { # shape_case <label> <expected message> [stage env assignments handled by caller]
  skip_genomic
  snap
  run_deploy auth
  check "$1: refused" refused "$2"
  check "$1: container not started" not_in_log 'systemctl start'
}
new_env shape-top
PART_EXTRA_ROWS="allObservationsStore.javabin\t3\t$(printf 'a%.0s' {1..64})\t\"e\"\tx\n" stage_partitioned auth "$KEY"
shape_case "top-level store in a partitioned manifest" "dest not allowed in a partitioned"
new_env shape-top-meta
PART_EXTRA_ROWS="columnMeta.javabin\t3\t$(printf 'a%.0s' {1..64})\t\"e\"\tx\n" stage_partitioned auth "$KEY"
shape_case "top-level columnMeta in a partitioned manifest" "dest not allowed in a partitioned"
new_env shape-static
PART_EXTRA_ROWS="static/x.json\t3\t$(printf 'a%.0s' {1..64})\t\"e\"\tx\n" stage_partitioned auth "$KEY"
shape_case "an unlisted extra dest" "dest not allowed in a partitioned"
new_env shape-deep
PART_EXTRA_ROWS="phenotypic/$P1/deeper/columnMeta.javabin\t3\t$(printf 'a%.0s' {1..64})\t\"e\"\tx\n" stage_partitioned auth "$KEY"
shape_case "a nested partition directory" "dest not allowed in a partitioned"
new_env shape-onefile
PART_SKIP_ROW="phenotypic/$P2/columnMeta.javabin" stage_partitioned auth "$KEY"
shape_case "a partition with one file" "every partition needs both"
new_env shape-nokey
PART_SKIP_ROW=encryption_key stage_partitioned auth "$KEY"
shape_case "no encryption_key" "exactly one encryption_key"
new_env shape-nometa
PART_SKIP_ROW=metadata.json stage_partitioned auth "$KEY"
shape_case "no metadata.json" "exactly one metadata.json"
new_env shape-count
PART_DECLARED=2 stage_partitioned auth "$KEY"
shape_case "partition count differs from the header" "declares 2 partitions but lists 3"
new_env shape-nocount
PART_DECLARED=none stage_partitioned auth "$KEY"
shape_case "no '# partitions=' header" "exactly one '# partitions=' header"
new_env shape-dash
PART_DASH_SHA="phenotypic/$P1/allObservationsStore.javabin" stage_partitioned auth "$KEY"
shape_case "a store without a sha256" "needs a sha256 for every file"
new_env shape-layout
PART_LAYOUT_LINE="# layout=flat" stage_partitioned auth "$KEY"
shape_case "an unknown layout value" "unknown layout 'flat'"
new_env shape-layout2
PART_LAYOUT_LINE="# layout=tiled" stage_partitioned auth "$KEY"
shape_case "another unknown layout value" "unknown layout 'tiled'"
new_env shape-layout-twice
PART_EXTRA_HEADERS='# layout=partitioned\n' stage_partitioned auth "$KEY"
shape_case "two layout headers" "more than one '# layout='"
new_env shape-dup
PART_EXTRA_ROWS="encryption_key\t3\t$(printf 'a%.0s' {1..64})\t\"e\"\tx\n" stage_partitioned auth "$KEY"
shape_case "a duplicate dest" "duplicate dest"
new_env shape-empty
PART_NAMES="" PART_DECLARED=0 stage_partitioned auth "$KEY"
shape_case "no partitions" "lists no partitions"
new_env shape-wrongvariant
stage_partitioned auth "$KEY"
sed -i.bak 's/^# variant=auth/# variant=open/' "$(stage_dir auth "$KEY")/manifest.tsv"
shape_case "a partitioned manifest of the other variant" "variant 'open'"
new_env shape-flat-part
stage_variant auth "$KEY"
awk 'NR==2{print; print "# partitions=1"; next} {print}' "$(stage_dir auth "$KEY")/manifest.tsv" >"${CASE}/m" && cat "${CASE}/m" >"$(stage_dir auth "$KEY")/manifest.tsv"
shape_case "a flat manifest with '# partitions='" "no 'layout=partitioned'"
new_env shape-flat-pheno
EXTRA_ROWS="phenotypic/$P1/columnMeta.javabin\t3\t-\t\"e\"\tx\n" stage_variant auth "$KEY"
shape_case "a flat manifest listing phenotypic/" "must not list phenotypic/"
new_env shape-flat-manifest
EXTRA_ROWS="manifest.tsv\t3\t-\t\"e\"\tx\n" stage_variant auth "$KEY"
shape_case "a flat manifest listing manifest.tsv" "unsafe dest"
new_env shape-flat-previous
EXTRA_ROWS=".previous-phenotypic/x\t3\t-\t\"e\"\tx\n" stage_variant auth "$KEY"
shape_case "a dest under .previous-phenotypic" "unsafe dest"
new_env shape-top-missing
PART_SKIP_ROW=none stage_partitioned auth "$KEY"
skip_genomic
run_deploy auth
check "control: a well-formed partitioned manifest passes" rc_is_zero

echo "# open host, partitioned: removed=true alone, or removed=false with override=true"
stig_case() { # stig_case <label> <accept|refuse> <printf %b headers for a partitioned open manifest>
  new_env "stig-$1"
  PART_STIG_HEADERS=$3 stage_partitioned open "$KEY"
  snap
  run_deploy open
  if [[ $2 == accept ]]; then
    check "open partitioned, $1: deployed" rc_is_zero
  else
    check "open partitioned, $1: refused" refused "stigvars_override=true"
    check "open partitioned, $1: container not started" not_in_log 'systemctl start'
  fi
}
stig_case both-headers accept '# stigvars_removed=false\n# stigvars_override=true\n'
stig_case no-headers refuse ''
stig_case no-override refuse '# stigvars_removed=false\n'
stig_case no-removed refuse '# stigvars_override=true\n'
stig_case removed-true accept '# stigvars_removed=true\n'
stig_case removed-true-upper refuse '# stigvars_removed=TRUE\n'
stig_case removed-yes refuse '# stigvars_removed=yes\n'
stig_case removed-true-trailing-space refuse '# stigvars_removed=true \n'
stig_case removed-true-duplicate refuse '# stigvars_removed=true\n# stigvars_removed=true\n'
stig_case removed-true-override-false refuse '# stigvars_removed=true\n# stigvars_override=false\n'
stig_case override-alone refuse '# stigvars_override=true\n'
stig_case removed-true-override refuse '# stigvars_removed=true\n# stigvars_override=true\n'
stig_case removed-upper refuse '# stigvars_removed=FALSE\n# stigvars_override=true\n'
stig_case removed-trailing-space refuse '# stigvars_removed=false \n# stigvars_override=true\n'
stig_case override-false refuse '# stigvars_removed=false\n# stigvars_override=false\n'
stig_case override-upper refuse '# stigvars_removed=false\n# stigvars_override=TRUE\n'
stig_case override-trailing-space refuse '# stigvars_removed=false\n# stigvars_override=true \n'
stig_case duplicate-removed refuse '# stigvars_removed=false\n# stigvars_removed=false\n# stigvars_override=true\n'
stig_case duplicate-override refuse '# stigvars_removed=false\n# stigvars_override=true\n# stigvars_override=true\n'
stig_case removed-conflict refuse '# stigvars_removed=false\n# stigvars_removed=true\n# stigvars_override=true\n'
stig_case removed-empty refuse '# stigvars_removed=\n# stigvars_override=true\n'

# a changed partition whose columnMeta.javabin row carries the removal-release src; the others keep partitions/<p>/
new_env stig-removed-src
PART_STIG_HEADERS='# stigvars_removed=true\n' PART_OPEN_META_SRC="$P2" stage_partitioned open "$KEY"
check "fixture: the changed partition has the open/partitions src row" grep -q "open/partitions/${P2}/columnMeta.javabin\$" "$(stage_dir open "$KEY")/manifest.tsv"
check "fixture: the other partitions keep the plain src" grep -q "	phenotypic/${P1}/columnMeta.javabin\$" "$(stage_dir open "$KEY")/manifest.tsv"
run_deploy open
check "open partitioned, removed=true, mixed src rows: deployed" rc_is_zero
for p in "$P1" "$P2" "$P3"; do
  check "open partitioned, removed=true, mixed src rows: ${p} columnMeta deployed" file_is "${ROOT_DIR}/opt/local/hpds/phenotypic/${p}/columnMeta.javabin" "open:p1:phenotypic/${p}/columnMeta.javabin"
done

# stigvars/layout/partitions lines are headers: after the column header they are refused
late_case() { # late_case <label> <PART_STIG_HEADERS> <trailing line, printf %b> [flat]
  new_env "late-$1"
  if [[ ${4:-} == flat ]]; then
    EXTRA_ROWS=$3 stage_variant open "$KEY"
  else
    PART_STIG_HEADERS=$2 PART_EXTRA_ROWS=$3 stage_partitioned open "$KEY"
  fi
  snap
  run_deploy open
  check "open, $1: refused" refused "after the column header"
  check "open, $1: container not started" not_in_log 'systemctl start'
}
late_case removed-true-after-rows '' '# stigvars_removed=true\n'
late_case override-after-rows '# stigvars_removed=false\n' '# stigvars_override=true\n'
late_case removed-false-after-rows '# stigvars_override=true\n' '# stigvars_removed=false\n'
late_case layout-after-rows '# stigvars_removed=true\n' '# layout=partitioned\n'
late_case partitions-after-rows '# stigvars_removed=true\n' '# partitions=3\n'
late_case flat-removed-true-after-rows '' '# stigvars_removed=true\n' flat
late_case flat-layout-after-rows '' '# layout=partitioned\n' flat
stig_case removed-true-cr refuse '# stigvars_removed=true\r\n'

# flat open manifests: no header, removed=true pass; removed=false needs the override; anything else refused
stig_flat() { # stig_flat <label> <accept|refuse> <printf %b headers inserted after line 2>
  new_env "stigflat-$1"
  stage_variant open "$KEY"
  { head -n 2 "$(stage_dir open "$KEY")/manifest.tsv"; printf '%b' "$3"; tail -n +3 "$(stage_dir open "$KEY")/manifest.tsv"; } >"${CASE}/m"
  cat "${CASE}/m" >"$(stage_dir open "$KEY")/manifest.tsv"
  snap
  run_deploy open
  if [[ $2 == accept ]]; then
    check "open flat, $1: deployed" rc_is_zero
  else
    check "open flat, $1: refused" refused "stigvars_override=true"
  fi
}
stig_flat no-headers accept ''
stig_flat removed-true accept '# stigvars_removed=true\n'
stig_flat removed-false-override accept '# stigvars_removed=false\n# stigvars_override=true\n'
stig_flat removed-false refuse '# stigvars_removed=false\n'
stig_flat removed-false-override-false refuse '# stigvars_removed=false\n# stigvars_override=false\n'
stig_flat removed-other refuse '# stigvars_removed=maybe\n'
stig_flat removed-upper refuse '# stigvars_removed=False\n'
stig_flat removed-duplicate refuse '# stigvars_removed=true\n# stigvars_removed=true\n'
stig_flat override-alone refuse '# stigvars_override=true\n'
new_env stig-auth
stage_partitioned auth "$KEY"
skip_genomic
run_deploy auth
check "auth manifest without the headers is not affected" rc_is_zero

echo "# auth host refuses the global partition; the open host serves it"
for gname in global Global GLOBAL; do
  new_env "g-auth-${gname}"
  put_env auth "$ENV_TEMPLATE"
  echo "old-kept" >"$(kept_of auth)"
  PART_NAMES="$P1 $gname $P2" stage_partitioned auth "$KEY"
  skip_genomic
  snap
  run_deploy auth
  check "auth, partition '${gname}': refused" refused "lists the global partition"
  check "auth, partition '${gname}': no dataset file downloaded" not_in_log 'allObservationsStore'
  check "auth, partition '${gname}': container not started" not_in_log 'systemctl start'
  check "auth, partition '${gname}': old kept manifest still there" file_is "$(kept_of auth)" "old-kept"
done
new_env g-auth-others
put_env auth "$ENV_TEMPLATE"
PART_NAMES="$P1 globalx global-2 $P2" stage_partitioned auth "$KEY"
skip_genomic
run_deploy auth
check "auth, partitions merely starting with global: accepted" rc_is_zero
new_env g-auth-flat
stage_variant auth "$KEY"
EXTRA_ROWS='phenotypic/global/columnMeta.javabin\t1\t-\t"etag"\tx\n' stage_variant auth "$KEY"
skip_genomic
snap
run_deploy auth
check "auth, flat manifest listing phenotypic/global/: refused" refused "a flat manifest.tsv must not list phenotypic/"
for gname in global Global; do
  new_env "g-open-${gname}"
  put_env open "$ENV_TEMPLATE"
  PART_NAMES="$P1 $gname $P2" stage_partitioned open "$KEY"
  run_deploy open
  check "open, partition '${gname}': exits 0" rc_is_zero
  check "open, partition '${gname}': store deployed" file_is "$(part_path "$gname" allObservationsStore.javabin)" "open:p1:phenotypic/${gname}/allObservationsStore.javabin"
  check "open, partition '${gname}': 3 partition directories" [ "$(part_count)" = 3 ]
  check "open, partition '${gname}': container started" in_log 'systemctl start'
done

echo "# global guard: leading-tab rows, grep failure, kept manifest"
# A row with a leading tab is split by the shared block like any other (leading tabs are
# dropped), so the guard sees the same dest that would be deployed.
lead_tab() { awk -v p="$1" 'BEGIN{FS=OFS="\t"} index($1, p) == 1 {printf "\t"} {print}' "$2" >"$2.new" && mv "$2.new" "$2"; }
new_env g-auth-tab
put_env auth "$ENV_TEMPLATE"
echo "old-kept" >"$(kept_of auth)"
PART_NAMES="$P1 global $P2" stage_partitioned auth "$KEY"
lead_tab phenotypic/global/ "$(stage_dir auth "$KEY")/manifest.tsv"
skip_genomic
snap
run_deploy auth
check "auth, leading-tab global rows: refused" refused "lists the global partition"
check "auth, leading-tab global rows: no dataset file downloaded" not_in_log 'allObservationsStore'
check "auth, leading-tab global rows: container not started" not_in_log 'systemctl start'
new_env g-auth-tab-multi
put_env auth "$ENV_TEMPLATE"
PART_NAMES="$P1 global $P2" stage_partitioned auth "$KEY"
sed 's/\t/\t\t/' "$(stage_dir auth "$KEY")/manifest.tsv" >"${CASE}/m" && cp "${CASE}/m" "$(stage_dir auth "$KEY")/manifest.tsv"
skip_genomic
run_deploy auth
check "auth, tab-run manifest: refused (by the guard or the shared block)" rc_is_nonzero
check "auth, tab-run manifest: container not started" not_in_log 'systemctl start'
new_env g-open-tab
put_env open "$ENV_TEMPLATE"
PART_NAMES="$P1 global $P2" stage_partitioned open "$KEY"
lead_tab phenotypic/global/ "$(stage_dir open "$KEY")/manifest.tsv"
run_deploy open
check "open, leading-tab global rows: exits 0" rc_is_zero
check "open, leading-tab global rows: store deployed" file_is "$(part_path global allObservationsStore.javabin)" "open:p1:phenotypic/global/allObservationsStore.javabin"

# grep failing (status 2) while checking the dest list must refuse, never pass.
new_env g-auth-grepfail
put_env auth "$ENV_TEMPLATE"
echo "old-kept" >"$(kept_of auth)"
stage_partitioned auth "$KEY"
skip_genomic
snap
REAL_GREP=$(command -v grep)
cat >"${FAKEBIN}/grep" <<EOT
#!/usr/bin/env bash
for a in "\$@"; do
  if [[ "\$a" == *'phenotypic/global'* ]]; then echo "grep: fake failure" >&2; exit 2; fi
done
exec "$REAL_GREP" "\$@"
EOT
chmod +x "${FAKEBIN}/grep"
run_deploy auth
rm -f "${FAKEBIN}/grep"
check "auth, grep error in the guard: refused" refused "could not check manifest.tsv for the global partition"
check "auth, grep error in the guard: container not started" not_in_log 'systemctl start'

# The kept manifest of an unchanged dataset key is checked too.
for kept_row in 'phenotypic/global/allObservationsStore.javabin' 'phenotypic/GLOBAL/columnMeta.javabin' '\tphenotypic/global/columnMeta.javabin'; do
  new_env "g-auth-kept"
  stage_variant auth "$KEY"
  {
    printf '# bdc-hpds-deploy/1\n# variant=auth\n# layout=partitioned\n# partitions=2\n'
    printf 'dest\tbytes\tsha256\tetag\tsrc\n'
    printf '%b\t1\t-\t"etag"\tx\n' "$kept_row"
    printf 'phenotypic/p1/columnMeta.javabin\t1\t-\t"etag"\tx\n'
  } >"$(kept_of auth)"
  mkdir -p "${ROOT_DIR}/opt/local/hpds/phenotypic/global"
  cat >"${ROOT_DIR}/opt/picsure/deploy-script-last-execution-values.txt" <<EOT
export dataset_s3_object_key="${KEY}"
export genomic_dataset_s3_object_key="${GKEY}"
EOT
  snap
  run_deploy auth
  check "auth, kept manifest '${kept_row}', key unchanged: refused" refused "lists the global partition"
  check "auth, kept manifest '${kept_row}': container not started" not_in_log 'systemctl start'
done
new_env g-auth-kept-ok
stage_variant auth "$KEY"
{
  printf '# bdc-hpds-deploy/1\n# variant=auth\n# layout=partitioned\n# partitions=2\n'
  printf 'dest\tbytes\tsha256\tetag\tsrc\n'
  printf 'phenotypic/globalx/columnMeta.javabin\t1\t-\t"etag"\tx\n'
  printf 'phenotypic/p1/columnMeta.javabin\t1\t-\t"etag"\tx\n'
} >"$(kept_of auth)"
mkdir -p "${ROOT_DIR}/opt/local/hpds/phenotypic/p1"
cat >"${ROOT_DIR}/opt/picsure/deploy-script-last-execution-values.txt" <<EOT
export dataset_s3_object_key="${KEY}"
export genomic_dataset_s3_object_key="${GKEY}"
EOT
run_deploy auth
check "auth, kept manifest without global, key unchanged: kept" rc_zero_and_out_has "Skipping javabins download"

echo
echo "passed: ${pass}, failed: ${failed}"
[[ $failed -eq 0 ]]
