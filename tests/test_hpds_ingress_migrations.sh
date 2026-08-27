#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
container_name="picsure-hpds-ingress-mysql-$$"

cleanup() {
  docker rm -f "$container_name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker run --rm --detach --name "$container_name" \
  --env MYSQL_ALLOW_EMPTY_PASSWORD=1 \
  mysql:8.4 >/dev/null

for _ in $(seq 1 60); do
  mysql_init_log=$(docker logs "$container_name" 2>&1 || true)
  if [[ "$mysql_init_log" == *'MySQL init process done'* ]] && \
      docker exec "$container_name" mysqladmin ping --silent >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
docker exec "$container_name" mysqladmin ping --silent >/dev/null

assert_query() {
  local sql=$1
  local expected=$2
  local actual
  actual=$(docker exec "$container_name" mysql --batch --skip-column-names --user=root auth --execute "$sql")
  if [[ "$actual" != "$expected" ]]; then
    printf 'Expected:\n%s\nActual:\n%s\n' "$expected" "$actual" >&2
    return 1
  fi
}

test_environment() {
  local environment=$1
  local migration_dir="$repo_root/app-infrastructure/db/$environment/auth"

  docker exec "$container_name" mysql --user=root --execute \
    "DROP DATABASE IF EXISTS auth; CREATE DATABASE auth CHARACTER SET utf8 COLLATE utf8_bin;"

  while IFS= read -r migration; do
    sed '/^USE$/ { N; s/^USE\n/USE /; }' "$migration" | \
      docker exec --interactive "$container_name" mysql --user=root auth
  done < <(find "$migration_dir" -maxdepth 1 -type f -name 'V*.sql' | sort -V)

  assert_query \
    "SELECT name, type, value FROM access_rule WHERE name IN ('AR_ALLOW_HPDS_AUTH_INGRESS', 'AR_ALLOW_HPDS_OPEN_INGRESS') ORDER BY name;" \
    $'AR_ALLOW_HPDS_AUTH_INGRESS\t11\t^/hpds/auth(/.*)?$\nAR_ALLOW_HPDS_OPEN_INGRESS\t11\t^/hpds/open(/.*)?$'

  assert_query \
    "SELECT ar.name, GROUP_CONCAT(p.name ORDER BY p.name) FROM access_rule ar JOIN accessRule_privilege arp ON arp.accessRule_id = ar.uuid JOIN privilege p ON p.uuid = arp.privilege_id WHERE ar.name IN ('AR_ALLOW_HPDS_AUTH_INGRESS', 'AR_ALLOW_HPDS_OPEN_INGRESS') GROUP BY ar.name ORDER BY ar.name;" \
    $'AR_ALLOW_HPDS_AUTH_INGRESS\tMANAGED_PRIV_AUTH_ACCESS\nAR_ALLOW_HPDS_OPEN_INGRESS\tMANAGED_PRIV_OPEN_ACCESS'

  assert_query \
    "SELECT COUNT(*) FROM access_rule WHERE name = 'AR_ALLOW_OPEN_ACCESS_V3_GATEWAY';" \
    '0'

  assert_query \
    "SELECT COUNT(*) FROM accessRule_gate ag JOIN access_rule ar ON ar.uuid IN (ag.gate_id, ag.accessRule_id) WHERE ar.name IN ('AR_ALLOW_HPDS_AUTH_INGRESS', 'AR_ALLOW_HPDS_OPEN_INGRESS');" \
    '0'

  assert_query \
    "SELECT COUNT(*) FROM access_rule WHERE type = 17;" \
    '0'

  assert_query \
    "SELECT COUNT(*) FROM accessRule_privilege arp LEFT JOIN access_rule ar ON ar.uuid = arp.accessRule_id WHERE ar.uuid IS NULL;" \
    '0'

  assert_query \
    "SELECT COUNT(*) FROM accessRule_gate arg LEFT JOIN access_rule gate_rule ON gate_rule.uuid = arg.gate_id LEFT JOIN access_rule parent_rule ON parent_rule.uuid = arg.accessRule_id WHERE gate_rule.uuid IS NULL OR parent_rule.uuid IS NULL;" \
    '0'
}

test_environment bdc
test_environment aim-ahead
