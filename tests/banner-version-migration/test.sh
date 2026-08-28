#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -eq 0 ]] || (( $# % 2 != 0 )); then
    echo "usage: $0 <banner-occurrence-migration.sql> <banner-version-migration.sql> [...]" >&2
    exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
test_id="banner-version-$PPID-$$"
network_name="$test_id-network"
mysql_container="$test_id-mysql"
migration_files=("$@")

cleanup() {
    docker rm -f "$mysql_container" >/dev/null 2>&1 || true
    docker network rm "$network_name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

for migration_file in "${migration_files[@]}"; do
    if [[ ! -f "$migration_file" ]]; then
        echo "migration file not found: $migration_file" >&2
        exit 2
    fi
done

docker network create "$network_name" >/dev/null
docker run --detach --name "$mysql_container" --network "$network_name" \
    --env MYSQL_ROOT_PASSWORD=test --env MYSQL_DATABASE=picsure mysql:8.0 >/dev/null

mysql_ready=false
for _ in {1..60}; do
    if docker run --rm --network "$network_name" mysql:8.0 mysqladmin \
        --host="$mysql_container" --user=root --password=test ping --silent >/dev/null 2>&1; then
        mysql_ready=true
        break
    fi
    sleep 1
done
if [[ "$mysql_ready" != true ]]; then
    echo "MySQL did not accept TCP connections within 60 seconds" >&2
    exit 1
fi

mysql_exec() {
    docker exec --interactive "$mysql_container" mysql --user=root --password=test --batch --skip-column-names "$@"
}

for ((index = 0; index < ${#migration_files[@]}; index += 2)); do
    occurrence_migration="${migration_files[index]}"
    version_migration="${migration_files[index + 1]}"

    if [[ "$(realpath "$occurrence_migration")" == "$(realpath "$version_migration")" ]]; then
        echo "occurrence and version migrations must be distinct files" >&2
        exit 2
    fi

    mysql_exec --execute="DROP DATABASE picsure; CREATE DATABASE picsure;"
    mysql_exec < "$occurrence_migration"
    mysql_exec picsure < "$script_dir/before.sql"

    docker run --rm --network "$network_name" \
        --volume "$(cd "$(dirname "$version_migration")" && pwd)/$(basename "$version_migration"):/flyway/sql/V2__CREATE_BANNER_VERSION.sql:ro" \
        flyway/flyway:11.7.2 \
        -url="jdbc:mysql://$mysql_container:3306/picsure?allowPublicKeyRetrieval=true" -user=root -password=test \
        -baselineOnMigrate=true -baselineVersion=1 migrate

    actual_versions="$(mysql_exec picsure --execute="
        SELECT CONCAT(
            LOWER(BIN_TO_UUID(banner_uuid)), CHAR(9), version_number, CHAR(9),
            DATE_FORMAT(effective_at, '%Y-%m-%d %H:%i:%s.%f'), CHAR(9), actor
        )
        FROM banner_version
        ORDER BY banner_uuid;
    ")"
    expected_versions="$(printf '%s\n' \
        $'00000000-0000-0000-0000-000000000001\\t1\\t2026-08-27 12:00:00.000000\\tpublisher' \
        $'00000000-0000-0000-0000-000000000002\\t1\\t2026-08-27 13:00:00.000000\\tSYSTEM_MIGRATION' \
        $'00000000-0000-0000-0000-000000000003\\t1\\t2026-08-27 09:00:00.000000\\tSYSTEM_MIGRATION')"
    if [[ "$actual_versions" != "$expected_versions" ]]; then
        echo "unexpected banner version backfill for $version_migration" >&2
        diff <(printf '%s\n' "$expected_versions") <(printf '%s\n' "$actual_versions") || true
        exit 1
    fi

    constraint_result="$(mysql_exec picsure --execute="
        SELECT CONCAT(
            (SELECT COUNT(*) FROM information_schema.table_constraints
             WHERE table_schema = 'picsure' AND table_name = 'banner_version'
               AND constraint_name = 'uq_banner_version_number' AND constraint_type = 'UNIQUE'), ':',
            (SELECT COUNT(*) FROM information_schema.table_constraints
             WHERE table_schema = 'picsure' AND table_name = 'banner_version'
               AND constraint_name = 'fk_banner_version_occurrence' AND constraint_type = 'FOREIGN KEY')
        );
    ")"
    if [[ "$constraint_result" != "1:1" ]]; then
        echo "unexpected banner version constraints for $version_migration: $constraint_result" >&2
        exit 1
    fi
    echo "Banner version migration verified: $version_migration"
done
