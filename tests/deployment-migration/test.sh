#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
test_dir="$repo_root/tests/deployment-migration"
selection="${1:-all}"

mysql_image="mysql:8.0.43@sha256:ccf4fed7ff4b886aeb3573a1f5d5b509525ecff55a2d1e2653c27a5abdded309"
feature_flyway_image="flyway/flyway:11.7.2@sha256:8ace7d9825bb3ad1d6e14ee27b3a830b638ac841ba424b99b2d92aa65a99d484"
deployment_flyway_image="flyway/flyway:10.8@sha256:2f39377b52cdf1c70ffe9c1437aabed4e70fb716bb41323b03ee09ce17aaf292"
aio_contract_url="https://github.com/hms-dbmi/PIC-SURE-Migrations.git"
aio_contract_sha="05b1a77512dc0921570f0d442853fdcee75b8131"
bdc_release_control_url="https://github.com/hms-dbmi/pic-sure-bdc-release-control.git"
bdc_release_control_sha="1339c50749fadd1f2e55f8b5a5b68b3ab0422f9a"
bdc_infrastructure_url="https://github.com/hms-dbmi/pic-sure-bdc-infrastructure.git"
bdc_infrastructure_ref="pic_sure_api_rewrite"
bdc_infrastructure_sha="2f384ada6e84fc6c041741b83db940e1253e6bf6"

# AIM-AHEAD's release control is private and operator-managed. This local proof
# binds the user-confirmed public migration history as a tested baseline only.
aim_release_control_marker="PRIVATE_OPERATOR_MANAGED"
aim_infrastructure_url="https://github.com/hms-dbmi/pic-sure-bdc-infrastructure.git"
aim_infrastructure_ref="pic_sure_api_rewrite"
aim_infrastructure_sha="2f384ada6e84fc6c041741b83db940e1253e6bf6"

password="deployment-banner-proof"
test_id="deployment-banner-$PPID-$$"
network_name="$test_id-network"
mysql_container="$test_id-mysql"
tmp_parent="${TMPDIR:-/tmp}"
tmp_parent="${tmp_parent%/}"
tmp_root="$(mktemp -d "$tmp_parent/$test_id.XXXXXX")"
executed_results="$tmp_root/executed-results.tsv"
source_root="${DEPLOYMENT_PROOF_SOURCE_ROOT:-$tmp_root/sources}"
aio_source_root="${AIO_PROOF_SOURCE_ROOT:-$source_root/aio-contract}"
aio_contract_dir="$aio_source_root/tests/aio-deployment-migration"
deployment_flyway_version=""

cleanup() {
    docker rm -f "$mysql_container" >/dev/null 2>&1 || true
    docker network rm "$network_name" >/dev/null 2>&1 || true
    case "$tmp_root" in
        "$tmp_parent"/deployment-banner-*) rm -rf -- "$tmp_root" ;;
        *) echo "Refusing to remove unexpected temporary directory: $tmp_root" >&2 ;;
    esac
}
trap cleanup EXIT

case "$selection" in
    all|bdc:fresh|bdc:supported-upgrade|bdc:occurrence-only|aim-ahead:fresh|aim-ahead:supported-upgrade|aim-ahead:occurrence-only) ;;
    *)
        echo "usage: $0 [all|bdc:{fresh,supported-upgrade,occurrence-only}|aim-ahead:{fresh,supported-upgrade,occurrence-only}]" >&2
        exit 2
        ;;
esac

required_files=(
    "$test_dir/matrix.tsv"
    "$test_dir/feature-sql.sha256"
    "$test_dir/occurrence-intermediate-sql.sha256"
    "$test_dir/supported-data.sql"
    "$test_dir/occurrence-only.sql"
    "$repo_root/tests/banner-authorization-migration/test.sh"
    "$repo_root/tests/banner-authorization-migration/routes.tsv"
    "$repo_root/tests/banner-authorization-migration/verify_routes.py"
    "$repo_root/tests/banner-version-migration/test.sh"
)
for file in "${required_files[@]}"; do
    test -f "$file" || { echo "Missing required proof input: $file" >&2; exit 2; }
done

retry() {
    local description="$1"
    local attempt
    shift

    for attempt in 1 2 3; do
        if "$@"; then
            return 0
        fi
        if [[ "$attempt" != 3 ]]; then
            echo "$description failed on attempt $attempt; retrying" >&2
            sleep "$attempt"
        fi
    done
    echo "$description failed after 3 attempts" >&2
    return 1
}

checkout_commit() {
    local url="$1"
    local sha="$2"
    local destination="$3"

    git init --quiet "$destination"
    git -C "$destination" remote add origin "$url"
    retry "Fetching $url at $sha" git -C "$destination" fetch --quiet --depth 1 origin "$sha" || return 1
    git -C "$destination" checkout --quiet --detach FETCH_HEAD
}

assert_checkout() {
    local label="$1"
    local checkout="$2"
    local expected_sha="$3"
    local require_detached="${4:-true}"
    local actual_sha
    local status

    actual_sha="$(git -C "$checkout" rev-parse HEAD 2>/dev/null)" || {
        echo "$label is not a Git checkout: $checkout" >&2
        exit 1
    }
    if [[ "$actual_sha" != "$expected_sha" ]]; then
        echo "$label SHA mismatch: expected $expected_sha, got $actual_sha" >&2
        exit 1
    fi
    if [[ "$require_detached" == true ]] && git -C "$checkout" symbolic-ref --quiet HEAD >/dev/null; then
        echo "$label checkout must be detached at $expected_sha" >&2
        exit 1
    fi
    status="$(git -C "$checkout" status --porcelain --untracked-files=all)"
    if [[ -n "$status" ]]; then
        echo "$label checkout contains modified or untracked inputs:" >&2
        printf '%s\n' "$status" >&2
        exit 1
    fi
}

release_infrastructure_ref() {
    python3 - "$1" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    value = json.load(handle).get("infrastructure_git_hash")
if not isinstance(value, str) or not value.strip():
    raise SystemExit(f"Missing infrastructure_git_hash in {sys.argv[1]}")
print(value)
PY
}

prepare_aio_contract() {
    if [[ -z "${AIO_PROOF_SOURCE_ROOT:-}" && -z "${DEPLOYMENT_PROOF_SOURCE_ROOT:-}" ]]; then
        mkdir -p "$source_root"
        if ! checkout_commit "$aio_contract_url" "$aio_contract_sha" "$aio_source_root"; then
            echo "Pinned Ticket 15 AIO contract $aio_contract_sha is not reachable from $aio_contract_url." >&2
            echo "Publish Ticket 15 first, or set AIO_PROOF_SOURCE_ROOT to a clean checkout at that exact commit." >&2
            exit 1
        fi
        assert_checkout "Ticket 15 AIO contract" "$aio_source_root" "$aio_contract_sha"
    elif [[ -z "${AIO_PROOF_SOURCE_ROOT:-}" ]]; then
        assert_checkout "Ticket 15 AIO contract" "$aio_source_root" "$aio_contract_sha"
    else
        assert_checkout "Ticket 15 AIO contract" "$aio_source_root" "$aio_contract_sha" false
    fi

    for file in "$aio_contract_dir/banner-schema.tsv" "$aio_contract_dir/feature-sql.sha256"; do
        test -f "$file" || { echo "Missing pinned Ticket 15 AIO contract file: $file" >&2; exit 1; }
    done
}

prepare_tenant_source() {
    local tenant="$1"
    local release_url="$2"
    local release_sha="$3"
    local infrastructure_url="$4"
    local expected_infrastructure_ref="$5"
    local infrastructure_sha="$6"
    local tenant_root="$source_root/$tenant"
    local infrastructure_ref

    if [[ -z "${DEPLOYMENT_PROOF_SOURCE_ROOT:-}" ]]; then
        mkdir -p "$tenant_root"
        checkout_commit "$release_url" "$release_sha" "$tenant_root/release-control"
        checkout_commit "$infrastructure_url" "$infrastructure_sha" "$tenant_root/infrastructure"
    fi

    assert_checkout "$tenant release control" "$tenant_root/release-control" "$release_sha"
    assert_checkout "$tenant infrastructure" "$tenant_root/infrastructure" "$infrastructure_sha"
    infrastructure_ref="$(release_infrastructure_ref "$tenant_root/release-control/build-spec.json")"
    if [[ "$infrastructure_ref" != "$expected_infrastructure_ref" ]]; then
        echo "$tenant release input expected infrastructure ref $expected_infrastructure_ref, got $infrastructure_ref" >&2
        exit 1
    fi
}

prepare_aim_source() {
    local tenant_root="$source_root/aim-ahead"

    if [[ -z "${DEPLOYMENT_PROOF_SOURCE_ROOT:-}" ]]; then
        mkdir -p "$tenant_root"
        checkout_commit "$aim_infrastructure_url" "$aim_infrastructure_sha" "$tenant_root/infrastructure"
    fi
    assert_checkout "AIM-AHEAD infrastructure" "$tenant_root/infrastructure" "$aim_infrastructure_sha"
}

verify_release_overlap() {
    local tenant="$1"
    local source="$source_root/$tenant/infrastructure/app-infrastructure/db/$tenant"
    local section
    local applied_file
    local relative

    for section in auth picsure; do
        for applied_file in "$source/$section"/V*.sql; do
            relative="${applied_file#"$source/"}"
            cmp "$applied_file" "$repo_root/app-infrastructure/db/$tenant/$relative" >/dev/null || {
                echo "$tenant applied release migration changed: $relative" >&2
                exit 1
            }
        done
    done
}

verify_checksum_manifest() {
    python3 - "$repo_root" "$1" <<'PY'
import hashlib
import sys
from pathlib import Path

root = Path(sys.argv[1])
for line in Path(sys.argv[2]).read_text(encoding="utf-8").splitlines():
    expected, relative = line.split("\t", 1)
    actual = hashlib.sha256((root / relative).read_bytes()).hexdigest()
    if actual != expected:
        raise SystemExit(
            f"Checksum mismatch for {relative}: expected {expected}, got {actual}"
        )
PY
}

verify_cross_deployment_sql_parity() {
    python3 - "$aio_contract_dir/feature-sql.sha256" "$test_dir/feature-sql.sha256" <<'PY'
import sys
from pathlib import Path

aio_paths = [
    "Baseline/auth/V6__ADD_BANNER_MANAGEMENT_ACCESS_RULE.sql",
    "Baseline/auth/V7__EXPAND_BANNER_MANAGEMENT_ACCESS_RULE.sql",
    "Baseline/auth/V8__AUTHORIZE_BANNER_REORDER.sql",
    "Baseline/auth/V9__ALLOW_BANNER_DISABLE_ROUTE.sql",
    "Baseline/auth/V10__ALLOW_BANNER_ARCHIVE_ROUTE.sql",
    "Baseline/auth/V11__ALLOW_BANNER_RESTORE_ROUTE.sql",
    "Baseline/picsure/V10__CREATE_BANNER_OCCURRENCE.sql",
    "Baseline/picsure/V11__CREATE_BANNER_VERSION.sql",
    "Baseline/picsure/V12__CREATE_BANNER_PRIORITY_ALLOCATOR.sql",
]
deployment_paths = [
    "app-infrastructure/db/bdc/auth/V22__Add_Banner_Management_Access_Rule.sql",
    "app-infrastructure/db/bdc/auth/V23__Expand_Banner_Management_Access_Rule.sql",
    "app-infrastructure/db/bdc/auth/V24__Authorize_Banner_Reorder.sql",
    "app-infrastructure/db/bdc/auth/V25__Allow_Banner_Disable_Route.sql",
    "app-infrastructure/db/bdc/auth/V26__Allow_Banner_Archive_Route.sql",
    "app-infrastructure/db/bdc/auth/V27__Allow_Banner_Restore_Route.sql",
    "app-infrastructure/db/bdc/picsure/V9__CREATE_BANNER_OCCURRENCE.sql",
    "app-infrastructure/db/bdc/picsure/V10__CREATE_BANNER_VERSION.sql",
    "app-infrastructure/db/bdc/picsure/V11__CREATE_BANNER_PRIORITY_ALLOCATOR.sql",
    "app-infrastructure/db/aim-ahead/auth/V24__Add_Banner_Management_Access_Rule.sql",
    "app-infrastructure/db/aim-ahead/auth/V25__Expand_Banner_Management_Access_Rule.sql",
    "app-infrastructure/db/aim-ahead/auth/V26__Authorize_Banner_Reorder.sql",
    "app-infrastructure/db/aim-ahead/auth/V27__Allow_Banner_Disable_Route.sql",
    "app-infrastructure/db/aim-ahead/auth/V28__Allow_Banner_Archive_Route.sql",
    "app-infrastructure/db/aim-ahead/auth/V29__Allow_Banner_Restore_Route.sql",
    "app-infrastructure/db/aim-ahead/picsure/V9__CREATE_BANNER_OCCURRENCE.sql",
    "app-infrastructure/db/aim-ahead/picsure/V10__CREATE_BANNER_VERSION.sql",
    "app-infrastructure/db/aim-ahead/picsure/V11__CREATE_BANNER_PRIORITY_ALLOCATOR.sql",
]


def read_rows(path):
    rows = [line.split("\t", 1) for line in Path(path).read_text(encoding="utf-8").splitlines()]
    if any(len(row) != 2 for row in rows):
        raise SystemExit(f"Malformed checksum manifest: {path}")
    return rows


aio_rows = read_rows(sys.argv[1])
deployment_rows = read_rows(sys.argv[2])
if [path for _, path in aio_rows] != aio_paths:
    raise SystemExit(f"Unexpected Ticket 15 AIO feature manifest paths: {sys.argv[1]}")
if [path for _, path in deployment_rows] != deployment_paths:
    raise SystemExit(f"Unexpected BDC/AIM feature manifest paths: {sys.argv[2]}")

aio_checksums = [checksum for checksum, _ in aio_rows]
for offset in (0, 9):
    deployment = "BDC" if offset == 0 else "AIM-AHEAD"
    actual = [checksum for checksum, _ in deployment_rows[offset:offset + 9]]
    if actual != aio_checksums:
        raise SystemExit(f"{deployment} feature SQL does not match pinned Ticket 15 AIO contract")
print("AIO/BDC/AIM corresponding feature SQL checksums MATCH")
PY
}

verify_matrix_contract() {
    python3 - "$test_dir/matrix.tsv" "$bdc_release_control_sha" "$bdc_infrastructure_sha" \
        "$aim_release_control_marker" "$aim_infrastructure_sha" "$aim_infrastructure_ref" "$mysql_image" "$feature_flyway_image" \
        "$deployment_flyway_image" "$deployment_flyway_version" <<'PY'
import csv
import sys


def require(condition, message):
    if not condition:
        raise SystemExit(message)


expected_header = [
    "deployment", "cell", "starting_state", "forward_migration_range", "release_control_sha",
    "core_auth_source", "core_picsure_source", "custom_start_source", "mysql_image",
    "flyway_test_image", "deployment_migration_image", "deployment_flyway_version",
    "start_custom_auth_max", "start_custom_picsure_max", "final_custom_auth_max",
    "final_custom_picsure_max", "result", "feature_sql_checksum_result", "remaining_assumptions",
]
with open(sys.argv[1], encoding="utf-8", newline="") as handle:
    reader = csv.DictReader(handle, delimiter="\t")
    require(reader.fieldnames == expected_header, f"Unexpected matrix header: {reader.fieldnames!r}")
    rows = list(reader)

expected_cells = [
    (deployment, cell)
    for deployment in ("BDC", "AIM-AHEAD")
    for cell in ("fresh", "supported-upgrade", "occurrence-only")
]
actual_cells = [(row["deployment"], row["cell"]) for row in rows]
require(actual_cells == expected_cells, f"Unexpected matrix cells: {actual_cells!r}")
expected = {
    "BDC": (sys.argv[2], sys.argv[3], "27", "11"),
    "AIM-AHEAD": (sys.argv[4], sys.argv[5], "29", "11"),
}
for row in rows:
    release_sha, infrastructure_sha, auth_max, picsure_max = expected[row["deployment"]]
    label = f'{row["deployment"]} {row["cell"]}'
    require(row["release_control_sha"] == release_sha, f"{label} release-control marker mismatch")
    require(infrastructure_sha in row["custom_start_source"], f"{label} infrastructure SHA mismatch")
    if row["deployment"] == "AIM-AHEAD":
        require(sys.argv[6] in row["custom_start_source"], f"{label} infrastructure ref mismatch")
    require(row["mysql_image"] == sys.argv[7], f"{label} MySQL image mismatch")
    require(row["flyway_test_image"] == sys.argv[8], f"{label} feature Flyway image mismatch")
    require(row["deployment_migration_image"] == sys.argv[9], f"{label} deployment Flyway image mismatch")
    require(row["deployment_flyway_version"] == sys.argv[10], f"{label} deployment Flyway version mismatch")
    require(row["final_custom_auth_max"] == auth_max, f"{label} final auth history mismatch")
    require(row["final_custom_picsure_max"] == picsure_max, f"{label} final PIC-SURE history mismatch")
    require(row["result"] == "PASS", f"{label} result must be PASS")
    require(row["feature_sql_checksum_result"] == "MATCH", f"{label} parity result must be MATCH")
    for field in ("starting_state", "forward_migration_range", "core_auth_source", "core_picsure_source", "remaining_assumptions"):
        require(row[field].strip(), f"{label} field {field} must not be empty")
PY
}

read_deployment_flyway_version() {
    local output
    local version

    output="$(docker run --rm "$deployment_flyway_image" -v 2>&1)"
    version="$(printf '%s\n' "$output" | sed -nE 's/^Flyway .* Edition ([^ ]+) by Redgate$/\1/p')"
    if [[ -z "$version" || "$version" == *$'\n'* ]]; then
        echo "Could not read one Flyway version from $deployment_flyway_image:" >&2
        printf '%s\n' "$output" >&2
        exit 1
    fi
    deployment_flyway_version="$version"
    echo "Deployment Flyway runtime version: $deployment_flyway_version"
}

start_mysql() {
    local mysql_ready=false

    docker network create "$network_name" >/dev/null
    docker run --detach --name "$mysql_container" --network "$network_name" \
        --env MYSQL_ROOT_PASSWORD="$password" "$mysql_image" >/dev/null
    for _ in {1..60}; do
        if docker exec --env MYSQL_PWD="$password" "$mysql_container" \
            mysqladmin --protocol=TCP --host=127.0.0.1 --user=root ping --silent >/dev/null 2>&1; then
            mysql_ready=true
            break
        fi
        sleep 1
    done
    if [[ "$mysql_ready" != true ]]; then
        echo "MySQL did not accept connections within 60 seconds" >&2
        exit 1
    fi
}

mysql_exec() {
    docker exec --interactive --env MYSQL_PWD="$password" "$mysql_container" \
        mysql --protocol=TCP --host=127.0.0.1 --user=root --batch --skip-column-names "$@"
}

reset_databases() {
    mysql_exec --execute="DROP DATABASE IF EXISTS auth; DROP DATABASE IF EXISTS picsure; CREATE DATABASE auth; CREATE DATABASE picsure;"
}

run_flyway() {
    local schema="$1"
    local migrations="$2"
    local target="${3:-}"
    local options=(
        -url="jdbc:mysql://$mysql_container:3306/$schema?allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC"
        -user=root
        -password="$password"
        -locations=filesystem:/flyway/sql
        -connectRetries=30
        -validateMigrationNaming=true
        -baselineOnMigrate=true
        -baselineVersion=0
        -placeholders.picsure_token_introspection_token=synthetic-token
        -placeholders.connection_label=Synthetic
        -placeholders.connection_id=synthetic
        -placeholders.connection_sub_prefix=synthetic
        -placeholders.include_auth_hpds=false
        -placeholders.include_open_hpds=false
    )
    if [[ -n "$target" ]]; then
        options+=(-target="$target")
    fi

    docker run --rm --network "$network_name" \
        --volume "$(realpath "$migrations"):/flyway/sql:ro" \
        "$deployment_flyway_image" "${options[@]}" migrate
}

assert_equal() {
    local actual="$1"
    local expected="$2"
    local description="$3"

    if [[ "$actual" != "$expected" ]]; then
        echo "$description: expected '$expected', got '$actual'" >&2
        exit 1
    fi
}

assert_history() {
    local schema="$1"
    local expected_max="$2"
    local expected_count="$3"
    local actual

    actual="$(mysql_exec "$schema" --execute="SELECT CONCAT(MAX(CAST(version AS UNSIGNED)), ':', COUNT(*)) FROM flyway_schema_history WHERE success=1;")"
    assert_equal "$actual" "$expected_max:$expected_count" "$schema migration history"
}

insert_ordinary_user_role() {
    mysql_exec auth --execute="
        INSERT INTO role (uuid, name, description)
        VALUES (UUID_TO_BIN('cccccccc-cccc-cccc-cccc-cccccccccccc'), 'PIC-SURE User', 'Synthetic ordinary user');"
}

assert_schema() {
    local tenant="$1"
    local actual="$tmp_root/$tenant-banner-schema.tsv"

    mysql_exec --execute="
        SELECT table_name, ordinal_position, column_name, column_type, is_nullable
        FROM information_schema.columns
        WHERE table_schema='picsure'
          AND table_name IN ('banner_occurrence', 'banner_version', 'banner_priority_allocator')
        ORDER BY FIELD(table_name, 'banner_occurrence', 'banner_version', 'banner_priority_allocator'), ordinal_position;
    " > "$actual"
    diff -u "$aio_contract_dir/banner-schema.tsv" "$actual"

    assert_equal "$(mysql_exec --execute="
        SELECT GROUP_CONCAT(column_name ORDER BY ordinal_position)
        FROM information_schema.key_column_usage
        WHERE constraint_schema='picsure' AND table_name='banner_occurrence' AND constraint_name='PRIMARY';")" \
        "uuid" "$tenant banner_occurrence primary key"
    assert_equal "$(mysql_exec --execute="
        SELECT GROUP_CONCAT(column_name ORDER BY ordinal_position)
        FROM information_schema.key_column_usage
        WHERE constraint_schema='picsure' AND table_name='banner_version' AND constraint_name='PRIMARY';")" \
        "uuid" "$tenant banner_version primary key"
    assert_equal "$(mysql_exec --execute="
        SELECT GROUP_CONCAT(column_name ORDER BY ordinal_position)
        FROM information_schema.key_column_usage
        WHERE constraint_schema='picsure' AND table_name='banner_priority_allocator' AND constraint_name='PRIMARY';")" \
        "id" "$tenant banner_priority_allocator primary key"
    assert_equal "$(mysql_exec --execute="
        SELECT GROUP_CONCAT(CONCAT(column_name, '->', referenced_table_schema, '.', referenced_table_name, '.', referenced_column_name) ORDER BY ordinal_position)
        FROM information_schema.key_column_usage
        WHERE constraint_schema='picsure' AND table_name='banner_occurrence' AND constraint_name='fk_banner_occurrence_restore';")" \
        "restored_from_uuid->picsure.banner_occurrence.uuid" "$tenant banner occurrence restore foreign key"
    assert_equal "$(mysql_exec --execute="
        SELECT GROUP_CONCAT(CONCAT(column_name, '->', referenced_table_schema, '.', referenced_table_name, '.', referenced_column_name) ORDER BY ordinal_position)
        FROM information_schema.key_column_usage
        WHERE constraint_schema='picsure' AND table_name='banner_version' AND constraint_name='fk_banner_version_occurrence';")" \
        "banner_uuid->picsure.banner_occurrence.uuid" "$tenant banner version occurrence foreign key"
    assert_equal "$(mysql_exec --execute="
        SELECT GROUP_CONCAT(k.column_name ORDER BY k.ordinal_position)
        FROM information_schema.key_column_usage k
        JOIN information_schema.table_constraints t
          ON t.constraint_schema=k.constraint_schema AND t.table_name=k.table_name AND t.constraint_name=k.constraint_name
        WHERE k.constraint_schema='picsure' AND k.table_name='banner_version'
          AND k.constraint_name='uq_banner_version_number' AND t.constraint_type='UNIQUE';")" \
        "banner_uuid,version_number" "$tenant banner version number unique constraint"
    assert_equal "$(mysql_exec --execute="
        SELECT LOWER(REPLACE(REPLACE(check_clause, CHAR(96), ''), ' ', ''))
        FROM information_schema.check_constraints
        WHERE constraint_schema='picsure' AND constraint_name='chk_banner_priority_allocator_singleton';")" \
        "(id=1)" "$tenant banner priority allocator singleton check"
    assert_equal "$(mysql_exec --execute="
        SELECT GROUP_CONCAT(column_name ORDER BY seq_in_index)
        FROM information_schema.statistics
        WHERE table_schema='picsure' AND table_name='banner_occurrence' AND index_name='idx_banner_occurrence_active';")" \
        "status,start_at,end_at,priority" "$tenant active banner index"
    assert_equal "$(mysql_exec --execute="
        SELECT GROUP_CONCAT(column_name ORDER BY seq_in_index)
        FROM information_schema.statistics
        WHERE table_schema='picsure' AND table_name='banner_occurrence' AND index_name='idx_banner_occurrence_priority';")" \
        "priority" "$tenant banner priority index"
}

assert_authorization() {
    local tenant="$1"
    local pattern
    local granted_roles

    pattern="$(mysql_exec auth --execute="SELECT value FROM access_rule WHERE name='AR_BANNER_MANAGEMENT_GATEWAY';")"
    granted_roles="$(mysql_exec auth --execute="
        SELECT GROUP_CONCAT(r.name ORDER BY r.name SEPARATOR ',')
        FROM role r
        JOIN role_privilege rp ON rp.role_id=r.uuid
        JOIN privilege p ON p.uuid=rp.privilege_id
        WHERE p.name='BANNER_MANAGEMENT';")"
    assert_equal "$granted_roles" "Admin,PIC-SURE Top Admin" "$tenant banner management roles"
    assert_equal "$(mysql_exec auth --execute="
        SELECT COUNT(*) FROM role r
        JOIN role_privilege rp ON rp.role_id=r.uuid
        JOIN privilege p ON p.uuid=rp.privilege_id
        WHERE r.name='PIC-SURE User' AND p.name='BANNER_MANAGEMENT';")" "0" "$tenant ordinary-user denial"
    assert_equal "$(mysql_exec auth --execute="
        SELECT COUNT(*) FROM privilege p
        JOIN application a ON a.uuid=p.application_id
        WHERE p.name='BANNER_MANAGEMENT' AND a.name='PICSURE';")" \
        "1" "$tenant banner privilege application ownership"
    assert_equal "$(mysql_exec auth --execute="
        SELECT COUNT(*) FROM accessRule_privilege arp
        JOIN privilege p ON p.uuid=arp.privilege_id
        JOIN access_rule ar ON ar.uuid=arp.accessRule_id
        WHERE p.name='BANNER_MANAGEMENT' AND ar.name='AR_BANNER_MANAGEMENT_GATEWAY';")" \
        "1" "$tenant banner access-rule privilege link"
    assert_equal "$(mysql_exec auth --execute="SELECT COUNT(*) FROM privilege WHERE name='BANNER_MANAGEMENT';")" \
        "1" "$tenant banner privilege uniqueness"
    assert_equal "$(mysql_exec auth --execute="SELECT COUNT(*) FROM access_rule WHERE name='AR_BANNER_MANAGEMENT_GATEWAY';")" \
        "1" "$tenant banner access-rule uniqueness"

    python3 "$repo_root/tests/banner-authorization-migration/verify_routes.py" \
        "$pattern" "$repo_root/tests/banner-authorization-migration/routes.tsv" "$tenant"
}

record_matrix_result() {
    local deployment="$1"
    local cell="$2"
    local start_auth="$3"
    local start_picsure="$4"
    local final_auth
    local final_picsure

    final_auth="$(mysql_exec auth --execute="SELECT MAX(CAST(version AS UNSIGNED)) FROM flyway_schema_history WHERE success=1;")"
    final_picsure="$(mysql_exec picsure --execute="SELECT MAX(CAST(version AS UNSIGNED)) FROM flyway_schema_history WHERE success=1;")"
    if [[ ! -f "$executed_results" ]]; then
        printf 'deployment\tcell\tstart_custom_auth_max\tstart_custom_picsure_max\tfinal_custom_auth_max\tfinal_custom_picsure_max\tresult\tfeature_sql_checksum_result\n' > "$executed_results"
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\tPASS\tMATCH\n' \
        "$deployment" "$cell" "$start_auth" "$start_picsure" "$final_auth" "$final_picsure" >> "$executed_results"
}

verify_matrix_results() {
    python3 - "$test_dir/matrix.tsv" "$executed_results" "$selection" <<'PY'
import csv
import sys

with open(sys.argv[1], encoding="utf-8", newline="") as handle:
    expected = {(row["deployment"], row["cell"]): row for row in csv.DictReader(handle, delimiter="\t")}
with open(sys.argv[2], encoding="utf-8", newline="") as handle:
    actual = {(row["deployment"], row["cell"]): row for row in csv.DictReader(handle, delimiter="\t")}

if sys.argv[3] == "all":
    selected = set(expected)
else:
    tenant, cell = sys.argv[3].split(":", 1)
    selected = {("BDC" if tenant == "bdc" else "AIM-AHEAD", cell)}
if set(actual) != selected:
    raise SystemExit(f"Executed matrix cells mismatch: expected {selected!r}, got {set(actual)!r}")
for key in selected:
    for field, value in actual[key].items():
        if field not in {"deployment", "cell"}:
            expected_value = expected[key][field]
            if expected_value != value:
                raise SystemExit(
                    f"Executed matrix result mismatch for {key!r} field {field}: "
                    f"expected {expected_value!r}, got {value!r}"
                )
PY
}

run_tenant_cell() {
    local tenant="$1"
    local deployment="$2"
    local cell="$3"
    local pre_auth="$4"
    local final_auth="$5"
    local release_root="$source_root/$tenant/infrastructure/app-infrastructure/db/$tenant"
    local final_root="$repo_root/app-infrastructure/db/$tenant"
    local start_auth="NONE"
    local start_picsure="NONE"

    echo "Running $deployment matrix cell: $cell"
    reset_databases
    case "$cell" in
        fresh)
            run_flyway auth "$final_root/auth" "$pre_auth"
            insert_ordinary_user_role
            run_flyway auth "$final_root/auth"
            run_flyway picsure "$final_root/picsure"
            ;;
        supported-upgrade)
            run_flyway auth "$release_root/auth"
            run_flyway picsure "$release_root/picsure"
            start_auth="$(mysql_exec auth --execute="SELECT MAX(CAST(version AS UNSIGNED)) FROM flyway_schema_history WHERE success=1;")"
            start_picsure="$(mysql_exec picsure --execute="SELECT MAX(CAST(version AS UNSIGNED)) FROM flyway_schema_history WHERE success=1;")"
            insert_ordinary_user_role
            mysql_exec < "$test_dir/supported-data.sql"
            run_flyway auth "$final_root/auth"
            run_flyway picsure "$final_root/picsure"
            assert_equal "$(mysql_exec auth --execute="
                SELECT COUNT(*) FROM role
                WHERE uuid=UUID_TO_BIN('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa')
                  AND name='Synthetic preserved role' AND description='Synthetic deployment migration proof row';")" \
                "1" "$deployment supported-upgrade preserved role"
            assert_equal "$(mysql_exec auth --execute="
                SELECT COUNT(*) FROM privilege p
                JOIN application a ON a.uuid=p.application_id
                WHERE p.uuid=UUID_TO_BIN('dddddddd-dddd-dddd-dddd-dddddddddddd')
                  AND p.name='SYNTHETIC_PRESERVED_PRIVILEGE' AND p.description='Synthetic preserved privilege'
                  AND p.queryTemplate='synthetic-template' AND p.queryScope='[\"synthetic\"]' AND a.name='PICSURE';")" \
                "1" "$deployment supported-upgrade preserved privilege"
            assert_equal "$(mysql_exec auth --execute="
                SELECT COUNT(*) FROM access_rule
                WHERE uuid=UUID_TO_BIN('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee')
                  AND name='AR_SYNTHETIC_PRESERVED' AND description='Synthetic preserved access rule'
                  AND rule='synthetic-rule' AND type=99 AND value='synthetic-value';")" \
                "1" "$deployment supported-upgrade preserved access rule"
            assert_equal "$(mysql_exec auth --execute="
                SELECT COUNT(*) FROM accessRule_privilege
                WHERE privilege_id=UUID_TO_BIN('dddddddd-dddd-dddd-dddd-dddddddddddd')
                  AND accessRule_id=UUID_TO_BIN('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee');")" \
                "1" "$deployment supported-upgrade preserved access-rule privilege link"
            assert_equal "$(mysql_exec auth --execute="
                SELECT COUNT(*) FROM role_privilege
                WHERE role_id=UUID_TO_BIN('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa')
                  AND privilege_id=UUID_TO_BIN('dddddddd-dddd-dddd-dddd-dddddddddddd');")" \
                "1" "$deployment supported-upgrade preserved role privilege link"
            assert_equal "$(mysql_exec picsure --execute="
                SELECT COUNT(*) FROM user
                WHERE uuid=UUID_TO_BIN('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb')
                  AND subject='synthetic-banner-proof' AND userId='preserve-me' AND roles='SYNTHETIC';")" \
                "1" "$deployment supported-upgrade preserved PIC-SURE user"
            ;;
        occurrence-only)
            run_flyway auth "$release_root/auth"
            run_flyway picsure "$release_root/picsure"
            run_flyway picsure "$final_root/picsure" 9
            start_auth="$(mysql_exec auth --execute="SELECT MAX(CAST(version AS UNSIGNED)) FROM flyway_schema_history WHERE success=1;")"
            start_picsure="$(mysql_exec picsure --execute="SELECT MAX(CAST(version AS UNSIGNED)) FROM flyway_schema_history WHERE success=1;")"
            insert_ordinary_user_role
            mysql_exec < "$test_dir/occurrence-only.sql"
            run_flyway auth "$final_root/auth"
            run_flyway picsure "$final_root/picsure"
            assert_equal "$(mysql_exec picsure --execute="
                SELECT CONCAT(
                    (SELECT COUNT(*) FROM banner_version WHERE banner_uuid=UUID_TO_BIN('00000000-0000-0000-0000-000000000001') AND version_number=1 AND actor='publisher@example.org' AND effective_at='2026-08-27 12:00:00.000000'), ':',
                    (SELECT COUNT(*) FROM banner_version WHERE banner_uuid=UUID_TO_BIN('00000000-0000-0000-0000-000000000002') AND version_number=1 AND actor='SYSTEM_MIGRATION' AND effective_at='2026-08-27 13:00:00.000000'), ':',
                    (SELECT COUNT(*) FROM banner_version WHERE banner_uuid=UUID_TO_BIN('00000000-0000-0000-0000-000000000004') AND version_number=1 AND actor='expired-publisher@example.org' AND effective_at='2000-01-01 00:00:00.000000'), ':',
                    (SELECT COUNT(*) FROM banner_version WHERE banner_uuid=UUID_TO_BIN('00000000-0000-0000-0000-000000000005') AND version_number=1 AND actor='restorer@example.org' AND effective_at='2026-08-28 00:00:00.000000'), ':',
                    (SELECT COUNT(*) FROM banner_version WHERE banner_uuid=UUID_TO_BIN('00000000-0000-0000-0000-000000000003')), ':',
                    (SELECT COUNT(*) FROM banner_version)
                );")" "1:1:1:1:0:4" "$deployment occurrence version backfill"
            assert_equal "$(mysql_exec picsure --execute="
                SELECT GROUP_CONCAT(CONCAT(BIN_TO_UUID(uuid), '=', priority) ORDER BY priority SEPARATOR ',') FROM banner_occurrence;")" \
                "00000000-0000-0000-0000-000000000001=4,00000000-0000-0000-0000-000000000005=30,00000000-0000-0000-0000-000000000002=40,00000000-0000-0000-0000-000000000004=80,00000000-0000-0000-0000-000000000003=90" \
                "$deployment occurrence priorities without compaction"
            assert_equal "$(mysql_exec picsure --execute="
                SELECT COUNT(*) FROM banner_occurrence
                WHERE uuid=UUID_TO_BIN('00000000-0000-0000-0000-000000000005')
                  AND restored_from_uuid=UUID_TO_BIN('00000000-0000-0000-0000-000000000001');")" \
                "1" "$deployment restore linkage"
            ;;
    esac

    assert_history auth "$final_auth" "$final_auth"
    assert_history picsure 11 11
    assert_schema "$tenant"
    assert_authorization "$deployment"
    if [[ "$cell" == occurrence-only ]]; then
        assert_equal "$(mysql_exec picsure --execute="SELECT CONCAT(COUNT(*), ':', MIN(next_priority), ':', MAX(next_priority)) FROM banner_priority_allocator;")" \
            "1:41:41" "$deployment occurrence allocator"
    else
        assert_equal "$(mysql_exec picsure --execute="SELECT CONCAT(COUNT(*), ':', MIN(next_priority), ':', MAX(next_priority)) FROM banner_priority_allocator;")" \
            "1:1:1" "$deployment $cell allocator"
    fi
    record_matrix_result "$deployment" "$cell" "$start_auth" "$start_picsure"
    echo "$deployment matrix cell PASS: $cell"
}

prepare_aio_contract
case "$selection" in
    bdc:*)
        prepare_tenant_source bdc "$bdc_release_control_url" "$bdc_release_control_sha" "$bdc_infrastructure_url" "$bdc_infrastructure_ref" "$bdc_infrastructure_sha"
        verify_release_overlap bdc
        ;;
    aim-ahead:*)
        prepare_aim_source
        verify_release_overlap aim-ahead
        ;;
    all)
        prepare_tenant_source bdc "$bdc_release_control_url" "$bdc_release_control_sha" "$bdc_infrastructure_url" "$bdc_infrastructure_ref" "$bdc_infrastructure_sha"
        prepare_aim_source
        verify_release_overlap bdc
        verify_release_overlap aim-ahead
        ;;
esac
verify_checksum_manifest "$test_dir/feature-sql.sha256"
verify_checksum_manifest "$test_dir/occurrence-intermediate-sql.sha256"
verify_cross_deployment_sql_parity
read_deployment_flyway_version
verify_matrix_contract
start_mysql

case "$selection" in
    bdc:*) run_tenant_cell bdc BDC "${selection#*:}" 21 27 ;;
    aim-ahead:*) run_tenant_cell aim-ahead AIM-AHEAD "${selection#*:}" 23 29 ;;
    all)
        for cell in fresh supported-upgrade occurrence-only; do
            run_tenant_cell bdc BDC "$cell" 21 27
        done
        for cell in fresh supported-upgrade occurrence-only; do
            run_tenant_cell aim-ahead AIM-AHEAD "$cell" 23 29
        done
        "$repo_root/tests/banner-authorization-migration/test.sh"
        "$repo_root/tests/banner-version-migration/test.sh" \
            "$repo_root/app-infrastructure/db/bdc/picsure/V9__CREATE_BANNER_OCCURRENCE.sql" \
            "$repo_root/app-infrastructure/db/bdc/picsure/V10__CREATE_BANNER_VERSION.sql" \
            "$repo_root/app-infrastructure/db/bdc/picsure/V11__CREATE_BANNER_PRIORITY_ALLOCATOR.sql" \
            "$repo_root/app-infrastructure/db/aim-ahead/picsure/V9__CREATE_BANNER_OCCURRENCE.sql" \
            "$repo_root/app-infrastructure/db/aim-ahead/picsure/V10__CREATE_BANNER_VERSION.sql" \
            "$repo_root/app-infrastructure/db/aim-ahead/picsure/V11__CREATE_BANNER_PRIORITY_ALLOCATOR.sql"
        ;;
esac

verify_matrix_results
echo "Deployment-owned banner migration proof PASS: $selection"
