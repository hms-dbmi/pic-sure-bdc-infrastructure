#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fixture="$repo_root/tests/banner-authorization-migration/routes.tsv"
before="$repo_root/tests/banner-authorization-migration/before.sql"
bdc_add="$repo_root/app-infrastructure/db/bdc/auth/V22__Add_Banner_Management_Access_Rule.sql"
bdc_expand="$repo_root/app-infrastructure/db/bdc/auth/V23__Expand_Banner_Management_Access_Rule.sql"
bdc_reorder="$repo_root/app-infrastructure/db/bdc/auth/V24__Authorize_Banner_Reorder.sql"
bdc_disable="$repo_root/app-infrastructure/db/bdc/auth/V25__Allow_Banner_Disable_Route.sql"
aim_add="$repo_root/app-infrastructure/db/aim-ahead/auth/V24__Add_Banner_Management_Access_Rule.sql"
aim_expand="$repo_root/app-infrastructure/db/aim-ahead/auth/V25__Expand_Banner_Management_Access_Rule.sql"
aim_reorder="$repo_root/app-infrastructure/db/aim-ahead/auth/V26__Authorize_Banner_Reorder.sql"
aim_disable="$repo_root/app-infrastructure/db/aim-ahead/auth/V27__Allow_Banner_Disable_Route.sql"
container="banner-auth-infra-${GITHUB_RUN_ID:-local}-$$"
password="banner-auth-test"

for file in "$fixture" "$before" "$bdc_add" "$bdc_expand" "$bdc_reorder" "$bdc_disable" "$aim_add" "$aim_expand" "$aim_reorder" "$aim_disable"; do
  test -f "$file" || { echo "Missing required file: $file" >&2; exit 1; }
done
paths=(
  "$(realpath "$bdc_add")" "$(realpath "$bdc_expand")" "$(realpath "$bdc_reorder")" "$(realpath "$bdc_disable")"
  "$(realpath "$aim_add")" "$(realpath "$aim_expand")" "$(realpath "$aim_reorder")" "$(realpath "$aim_disable")"
)
test "$(printf '%s\n' "${paths[@]}" | sort -u | wc -l | tr -d ' ')" = "8"
cmp "$bdc_add" "$aim_add"
cmp "$bdc_expand" "$aim_expand"
cmp "$bdc_reorder" "$aim_reorder"
cmp "$bdc_disable" "$aim_disable"

cleanup() {
  docker rm -f "$container" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker run --name "$container" -e MYSQL_ROOT_PASSWORD="$password" -d mysql:8.0 >/dev/null
for _ in {1..60}; do
  if docker exec "$container" mysql -uroot -p"$password" -e "SELECT 1" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
docker exec "$container" mysql -uroot -p"$password" -e "SELECT 1" >/dev/null

mysql_exec() {
  docker exec -i "$container" mysql -uroot -p"$password" --batch --skip-column-names "$@"
}

verify_deployment() {
  local deployment="$1"
  local add_migration="$2"
  local expand_migration="$3"
  local reorder_migration="$4"
  local disable_migration="$5"

  mysql_exec < "$before"
  mysql_exec < "$add_migration"
  mysql_exec -e "UPDATE auth.access_rule SET value = 'unexpected-pre-expansion-value' WHERE name = 'AR_BANNER_MANAGEMENT_GATEWAY';"
  mysql_exec < "$expand_migration"
  mysql_exec -e "UPDATE auth.access_rule SET value = 'unexpected-pre-reorder-value' WHERE name = 'AR_BANNER_MANAGEMENT_GATEWAY';"
  mysql_exec < "$reorder_migration"
  mysql_exec -e "UPDATE auth.access_rule SET value = 'unexpected-pre-disable-value' WHERE name = 'AR_BANNER_MANAGEMENT_GATEWAY';"
  mysql_exec < "$disable_migration"

  local pattern granted_roles
  pattern="$(mysql_exec -e "SELECT value FROM auth.access_rule WHERE name = 'AR_BANNER_MANAGEMENT_GATEWAY';")"
  granted_roles="$(mysql_exec -e "
    SELECT GROUP_CONCAT(r.name ORDER BY r.name SEPARATOR ',')
    FROM auth.role r
    JOIN auth.role_privilege rp ON rp.role_id = r.uuid
    JOIN auth.privilege p ON p.uuid = rp.privilege_id
    WHERE p.name = 'BANNER_MANAGEMENT';")"
  test "$granted_roles" = "Admin,PIC-SURE Top Admin"
  test "$(mysql_exec -e "
    SELECT COUNT(*) FROM auth.role r
    JOIN auth.role_privilege rp ON rp.role_id = r.uuid
    JOIN auth.privilege p ON p.uuid = rp.privilege_id
    WHERE r.name = 'PIC-SURE User' AND p.name = 'BANNER_MANAGEMENT';")" = "0"

  python3 - "$pattern" "$fixture" "$deployment" <<'PY'
import re
import sys
from pathlib import Path

actual_pattern, fixture_path, deployment = sys.argv[1:]
entries = [line.split("\t", 1) for line in Path(fixture_path).read_text().splitlines()]
expected_pattern = next(value for kind, value in entries if kind == "pattern")
assert actual_pattern == expected_pattern, (deployment, actual_pattern, expected_pattern)
rule = re.compile(actual_pattern)
for kind, route in entries:
    if kind == "allow":
        assert rule.fullmatch(route), f"{deployment} expected allowed route: {route}"
    elif kind == "deny":
        assert not rule.fullmatch(route), f"{deployment} expected denied route: {route}"
PY
}

verify_deployment BDC "$bdc_add" "$bdc_expand" "$bdc_reorder" "$bdc_disable"
verify_deployment AIM "$aim_add" "$aim_expand" "$aim_reorder" "$aim_disable"
echo "BDC and AIM banner authorization migrations verified"
