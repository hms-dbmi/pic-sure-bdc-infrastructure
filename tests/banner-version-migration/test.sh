#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -eq 0 ]]; then
    echo "usage: $0 <banner-version-migration.sql> [...]" >&2
    exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
test_id="banner-version-$PPID-$$"
network_name="$test_id-network"
mysql_container="$test_id-mysql"

cleanup() {
    docker rm -f "$mysql_container" >/dev/null 2>&1 || true
    docker network rm "$network_name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker network create "$network_name" >/dev/null
docker run --detach --name "$mysql_container" --network "$network_name" \
    --env MYSQL_ROOT_PASSWORD=test --env MYSQL_DATABASE=picsure mysql:8.0 >/dev/null

until docker exec "$mysql_container" mysql --user=root --password=test --execute="SELECT 1" >/dev/null 2>&1; do
    sleep 1
done

for migration_file in "$@"; do
    if [[ ! -f "$migration_file" ]]; then
        echo "migration file not found: $migration_file" >&2
        exit 2
    fi

    docker exec "$mysql_container" mysql --user=root --password=test --execute="DROP DATABASE picsure; CREATE DATABASE picsure;"
    docker exec --interactive "$mysql_container" mysql --user=root --password=test picsure < "$script_dir/before.sql"

    docker run --rm --network "$network_name" \
        --volume "$(cd "$(dirname "$migration_file")" && pwd)/$(basename "$migration_file"):/flyway/sql/V2__CREATE_BANNER_VERSION.sql:ro" \
        flyway/flyway:11.7.2 \
        -url="jdbc:mysql://$mysql_container:3306/picsure?allowPublicKeyRetrieval=true" -user=root -password=test \
        -baselineOnMigrate=true -baselineVersion=1 migrate

    result="$(docker exec "$mysql_container" mysql --user=root --password=test --skip-column-names --batch picsure --execute="
        SELECT CONCAT(
            (SELECT COUNT(*) FROM banner_version), ':',
            (SELECT COUNT(*) FROM banner_version
             WHERE banner_uuid = UUID_TO_BIN('00000000-0000-0000-0000-000000000002')
               AND effective_at = '2026-08-27 13:00:00.000000'
               AND actor = 'SYSTEM_MIGRATION'), ':',
            (SELECT COUNT(*) FROM information_schema.table_constraints
             WHERE table_schema = 'picsure' AND table_name = 'banner_version'
               AND constraint_name = 'uq_banner_version_number' AND constraint_type = 'UNIQUE'), ':',
            (SELECT COUNT(*) FROM information_schema.table_constraints
             WHERE table_schema = 'picsure' AND table_name = 'banner_version'
               AND constraint_name = 'fk_banner_version_occurrence' AND constraint_type = 'FOREIGN KEY')
        );
    ")"
    if [[ "$result" != "2:1:1:1" ]]; then
        echo "unexpected banner version migration result for $migration_file: $result" >&2
        exit 1
    fi
done
