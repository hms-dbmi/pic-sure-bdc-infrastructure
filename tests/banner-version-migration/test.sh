#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -eq 0 ]] || (( $# % 3 != 0 )); then
    echo "usage: $0 <banner-occurrence.sql> <banner-version.sql> <banner-priority-allocator.sql> [...]" >&2
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

for ((index = 0; index < ${#migration_files[@]}; index += 3)); do
    occurrence_migration="${migration_files[index]}"
    version_migration="${migration_files[index + 1]}"
    priority_migration="${migration_files[index + 2]}"

    if [[ "$(realpath "$occurrence_migration")" == "$(realpath "$version_migration")" ]]; then
        echo "occurrence and version migrations must be distinct files" >&2
        exit 2
    fi
    if [[ "$(realpath "$occurrence_migration")" == "$(realpath "$priority_migration")" ]] ||
       [[ "$(realpath "$version_migration")" == "$(realpath "$priority_migration")" ]]; then
        echo "banner migrations must be distinct files" >&2
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

    snapshot_result="$(mysql_exec picsure --execute="
        SELECT CONCAT(
            (SELECT COUNT(*) FROM banner_version WHERE uuid IS NOT NULL
                AND banner_uuid = UUID_TO_BIN('00000000-0000-0000-0000-000000000001') AND version_number = 1
                AND BINARY html_content = BINARY '<p>Publication | time wins</p>' AND title = 'Published metadata'
                AND appearance = 'WARNING' AND icon = 'WARNING' AND dismissible = FALSE AND audience = 'SIGNED_IN'
                AND placement = 'SITE_TOP'
                AND page_targets = JSON_ARRAY(JSON_OBJECT('kind', 'EXACT', 'path', '/admin|status'))
                AND start_at = '2026-08-27 11:30:00.000000' AND end_at = '2026-08-28 12:00:00.000000'
                AND presentation_hash = REPEAT('a', 64) AND effective_at = '2026-08-27 12:00:00.000000'
                AND actor = 'publisher'), ':',
            (SELECT COUNT(*) FROM banner_version WHERE uuid IS NOT NULL
                AND banner_uuid = UUID_TO_BIN('00000000-0000-0000-0000-000000000002') AND version_number = 1
                AND BINARY html_content = BINARY '<p>Updated time fallback</p>' AND title = 'Updated metadata'
                AND appearance = 'PRIMARY' AND icon = 'INFORMATION' AND dismissible = TRUE AND audience = 'EVERYONE'
                AND placement = 'SITE_TOP' AND page_targets = JSON_ARRAY(JSON_OBJECT('kind', 'ALL'))
                AND start_at = '2026-08-27 13:00:00.000000' AND end_at = '2026-08-29 13:00:00.000000'
                AND presentation_hash = REPEAT('b', 64) AND effective_at = '2026-08-27 13:00:00.000000'
                AND actor = 'SYSTEM_MIGRATION'), ':',
            (SELECT COUNT(*) FROM banner_version WHERE uuid IS NOT NULL
                AND banner_uuid = UUID_TO_BIN('00000000-0000-0000-0000-000000000003') AND version_number = 1
                AND BINARY html_content = BINARY '<p>Created time fallback</p>' AND title = 'Created metadata'
                AND appearance = 'ERROR' AND icon = 'ERROR' AND dismissible = FALSE AND audience = 'SIGNED_OUT'
                AND placement = 'SITE_TOP'
                AND page_targets = JSON_ARRAY(JSON_OBJECT('kind', 'EXACT', 'path', '/created'))
                AND start_at = '2026-08-27 14:00:00.000000' AND end_at = '2026-08-30 14:00:00.000000'
                AND presentation_hash = REPEAT('c', 64) AND effective_at = '2026-08-27 09:00:00.000000'
                AND actor = 'SYSTEM_MIGRATION'), ':',
            (SELECT COUNT(*) FROM banner_version)
        );
    ")"
    if [[ "$snapshot_result" != "1:1:1:3" ]]; then
        echo "unexpected banner version snapshot for $version_migration: $snapshot_result" >&2
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
    mysql_exec picsure --execute="
        UPDATE banner_occurrence
        SET priority = 9, end_at = NULL
        WHERE uuid = UUID_TO_BIN('00000000-0000-0000-0000-000000000001');"
    mysql_exec < "$priority_migration"
    allocator_result="$(mysql_exec picsure --execute="
        SELECT CONCAT(
            (SELECT COUNT(*) FROM banner_priority_allocator WHERE id = 1 AND next_priority = 10), ':',
            (SELECT COUNT(*) FROM information_schema.table_constraints
             WHERE table_schema = 'picsure' AND table_name = 'banner_priority_allocator'
               AND constraint_name = 'chk_banner_priority_allocator_singleton' AND constraint_type = 'CHECK')
        );")"
    if [[ "$allocator_result" != "1:1" ]]; then
        echo "unexpected banner priority allocator for $priority_migration: $allocator_result" >&2
        exit 1
    fi
    echo "Banner version migration verified: $version_migration"
    echo "Banner priority allocator migration verified: $priority_migration"
done
