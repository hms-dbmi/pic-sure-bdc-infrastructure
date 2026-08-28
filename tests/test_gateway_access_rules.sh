#!/usr/bin/env bash
# Applies each auth migration chain to a throwaway MySQL and asserts that the
# access rules a gateway deployment actually needs exist, are attached to the
# right privileges, and that nothing PSAMA no longer implements survives.
#
# The gateway introspects with {"Target Service": <decoded path>} and no request
# body, so a rule on any other JsonPath can never resolve. The five rules
# asserted below are the whole authorization surface under the gateway.
#
# Requires docker. Creates and removes its own container; touches nothing else.
#
#   tests/test_gateway_access_rules.sh
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
db_root="$repo_root/app-infrastructure/db"
container="picsure-access-rule-test-$$"
work="$(mktemp -d)"
failures=0

cleanup() {
    docker rm -f "$container" >/dev/null 2>&1 || true
    rm -rf "$work"
}
trap cleanup EXIT

# --protocol=tcp on purpose: the mysql image runs a socket-only temporary server
# while it initialises, and a socket connection succeeds against that one
# seconds before the real server is listening.
mysql_run() {
    docker exec -i "$container" mysql -h127.0.0.1 --protocol=tcp -uroot -ptest \
        --default-character-set=utf8mb4 "$@" 2>/dev/null
}

# Flyway tolerates "USE\n`auth`;" and substitutes ${placeholders}; the mysql CLI
# does neither. The schema is always `auth`, because several migrations name it
# explicitly (V5's admin procedure, the logging rule).
prepare() {
    perl -0pe 's/\bUSE\s*\n\s*/USE /g' "$1" \
        | sed -e 's/${connection_id}/test-connection-id/g' \
              -e 's/${connection_label}/FENCE/g' \
              -e 's/${connection_sub_prefix}/sub/g' \
              -e 's/${picsure_token_introspection_token}/test-token/g'
}

apply_chain() {
    local label="$1" dir="$2" stop_before="${3:-}"
    mysql_run -e 'DROP DATABASE IF EXISTS `auth`; CREATE DATABASE `auth`;'
    local file count=0
    local files=()
    while IFS= read -r file; do files+=("$file"); done < <(ls "$dir" | sort -V)
    for file in "${files[@]}"; do
        [[ -n "$stop_before" && "$file" == "$stop_before" ]] && break
        prepare "$dir/$file" > "$work/current.sql"
        if ! mysql_run auth < "$work/current.sql"; then
            echo "FAIL  $label: $file did not apply"
            exit 1
        fi
        count=$((count + 1))
    done
    [[ -z "$stop_before" ]] && echo "ok    $label: $count migrations applied"
    return 0
}

query() { mysql_run -N -B auth -e "$1" | tr -d '\r'; }

expect() {
    local label="$1" actual="$2" wanted="$3"
    if [[ "$actual" == "$wanted" ]]; then
        echo "ok    $label"
    else
        echo "FAIL  $label"
        echo "        expected: $wanted"
        echo "        actual:   $actual"
        failures=$((failures + 1))
    fi
}

# rule name -> the privileges that must carry it, comma separated and sorted.
GATEWAY_RULES=(
    'AR_ALLOW_HPDS_AUTH_INGRESS|MANAGED_PRIV_AUTH_ACCESS'
    'AR_ALLOW_HPDS_OPEN_INGRESS|MANAGED_PRIV_OPEN_ACCESS'
    'AR_DICTIONARY_CLEAN_PREFIX|MANAGED_PRIV_DICTIONARY,MANAGED_PRIV_OPEN_ACCESS'
    'AR_VISUALIZATION_CLEAN_PREFIX|MANAGED_PRIV_OPEN_ACCESS'
    'AR_NAMED_DATASET_GATEWAY|MANUAL_PRIV_METADATA_ACCESS,MANUAL_PRIV_NAMED_DATASET'
)

assert_gateway_rules() {
    local label="$1" entry rule privileges actual
    # Iterating an array rather than a heredoc: query() shells out to
    # `docker exec -i`, which would swallow a `while read` loop's stdin.
    for entry in "${GATEWAY_RULES[@]}"; do
        rule="${entry%%|*}"
        privileges="${entry#*|}"
        actual="$(query "
            SELECT COALESCE(GROUP_CONCAT(p.name ORDER BY p.name SEPARATOR ','), 'UNATTACHED')
            FROM access_rule ar
            LEFT JOIN accessRule_privilege arp ON arp.accessRule_id = ar.uuid
            LEFT JOIN privilege p ON p.uuid = arp.privilege_id
            WHERE ar.name = '$rule';")"
        expect "$label: $rule -> $privileges" "$actual" "$privileges"
    done

    # AccessRule.TypeNaming stops at 16 and _decisionMaker's default refuses to
    # grant, so a surviving type-17 row is a permanent denial hanging off a
    # privilege every authenticated user holds.
    expect "$label: no consent (type 17) rules survive" \
        "$(query 'SELECT COUNT(*) FROM access_rule WHERE type = 17;')" "0"

    # A guard row only exists if a guarded INSERT matched no privilege, and that
    # case aborts the migration. Finding one means the guard itself is broken.
    expect "$label: no migration guard rows" \
        "$(query "SELECT COUNT(*) FROM access_rule WHERE name LIKE 'MIGRATION_GUARD%';")" "0"

    # /logging sits on the gateway's allow-list-prefixes and is never
    # introspected, so a clean-prefix rule for it would never be evaluated.
    expect "$label: no clean-prefix rule for /logging" \
        "$(query "SELECT COUNT(*) FROM access_rule WHERE value LIKE '^/logging%';")" "0"

    # The legacy /proxy rules are retained for WildFly until cutover, and
    # PrivilegeService's startup attachment loop no longer exists to bind them.
    # Each must carry a privilege of its own.
    for rule in AR_DICTIONARY_REQUESTS AR_LOGGING_REQUESTS; do
        expect "$label: $rule is attached" \
            "$(query "
                SELECT CASE WHEN COUNT(*) > 0 THEN 'attached' ELSE 'UNATTACHED' END
                FROM accessRule_privilege arp
                JOIN access_rule ar ON ar.uuid = arp.accessRule_id
                WHERE ar.name = '$rule';")" "attached"
    done
}

# Renaming the privilege an ingress rule attaches to must abort the migration
# rather than ship an unattached rule, which would be a silent denial.
assert_guard_fires() {
    local ingress=V21__Add_Gateway_HPDS_Ingress_Rules.sql
    apply_chain guard "$db_root/bdc/auth" "$ingress"
    mysql_run -e "UPDATE auth.privilege SET name = 'RENAMED_AWAY' WHERE name = 'MANAGED_PRIV_AUTH_ACCESS';"
    prepare "$db_root/bdc/auth/$ingress" > "$work/guard.sql"
    if mysql_run auth < "$work/guard.sql"; then
        echo "FAIL  guard: $ingress succeeded with MANAGED_PRIV_AUTH_ACCESS missing"
        failures=$((failures + 1))
    else
        echo "ok    guard: $ingress aborts when its privilege is missing"
    fi
}

docker run -d --rm --name "$container" -e MYSQL_ROOT_PASSWORD=test mysql:8.0 >/dev/null
ready=0
for _ in $(seq 1 90); do
    if mysql_run -e 'SELECT 1' >/dev/null 2>&1; then ready=1; break; fi
    sleep 1
done
if (( ready == 0 )); then
    echo "FAIL  mysql never became reachable"
    exit 1
fi

apply_chain bdc "$db_root/bdc/auth"
assert_gateway_rules bdc
apply_chain aim-ahead "$db_root/aim-ahead/auth"
assert_gateway_rules aim-ahead
assert_guard_fires

if (( failures > 0 )); then
    echo
    echo "$failures assertion(s) failed"
    exit 1
fi
echo
echo "all assertions passed"
