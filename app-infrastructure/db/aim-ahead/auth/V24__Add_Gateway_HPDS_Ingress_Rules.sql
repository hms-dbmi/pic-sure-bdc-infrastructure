-- The two HPDS ingress rules: one route grant per backend.
--
-- Under the gateway the query service selects the HPDS backend from the PATH
-- (/hpds/auth/... or /hpds/open/...), and the introspection payload the gateway
-- sends PSAMA is a single key, {"Target Service": <decoded path>}, with no
-- request body. The resourceUUID grants (V15's AR_ALLOW_OPEN_ACCESS_V3 and its
-- siblings) therefore cannot resolve any more: JsonPath $.query.resourceUUID
-- raises PathNotFound and the rule denies. The path is the only thing left to
-- authorize on.
--
-- Consent scoping is no longer an access rule. The HPDS query service fetches
-- the caller's consents with the caller's own token, injects the authorization
-- filters before it dispatches a query, and re-checks them when a stored result
-- is read back. These two rules are route grants and nothing more: they say
-- which backend a privilege may reach, not which data it may see. V25 retires
-- the consent rule type they replace.
--
-- The legacy resourceUUID rules are RETAINED for WildFly until cutover.

use auth;

-- ---- open backend -----------------------------------------------------------

SET @openHpdsIngress = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @openHpdsIngress, 'AR_ALLOW_HPDS_OPEN_INGRESS',
    'Allow access to the open HPDS backend through the gateway',
    '$.[\'Target Service\']', 11, '^/hpds/open(/.*)?$', 0x00, 0x00, NULL, 0x00, 0x00
);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT uuid, @openHpdsIngress
FROM privilege
WHERE name = 'MANAGED_PRIV_OPEN_ACCESS';

-- Fail the migration if that matched nothing (see V22 for the mechanism).
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT @openHpdsIngress, 'MIGRATION_GUARD_UNATTACHED_RULE',
       'MIGRATION GUARD: AR_ALLOW_HPDS_OPEN_INGRESS matched no privilege',
       '', 0, '', 0x00, 0x00, NULL, 0x00, 0x00
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM accessRule_privilege WHERE accessRule_id = @openHpdsIngress);

-- ---- auth backend -----------------------------------------------------------

SET @authHpdsIngress = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @authHpdsIngress, 'AR_ALLOW_HPDS_AUTH_INGRESS',
    'Allow access to the authorized HPDS backend through the gateway',
    '$.[\'Target Service\']', 11, '^/hpds/auth(/.*)?$', 0x00, 0x00, NULL, 0x00, 0x00
);

-- Every user who authenticates through FENCE, RAS or Okta receives
-- MANUAL_ROLE_AUTH_ACCESS from UserService.ensureBaselineRoles(), so this grant
-- reaches the whole authenticated population by design. It covers the auth
-- backend's search endpoints as well as its query lifecycle; the query service
-- applies consent filters to queries but not to /hpds/auth/search and
-- /hpds/auth/search/values, which return concept metadata from the
-- non-obfuscated store. That is the pre-gateway posture too, where the standard
-- rule AR_ONLY_SEARCH granted any path containing "/search" to every privilege.
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT uuid, @authHpdsIngress
FROM privilege
WHERE name = 'MANAGED_PRIV_AUTH_ACCESS';

INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT @authHpdsIngress, 'MIGRATION_GUARD_UNATTACHED_RULE',
       'MIGRATION GUARD: AR_ALLOW_HPDS_AUTH_INGRESS matched no privilege',
       '', 0, '', 0x00, 0x00, NULL, 0x00, 0x00
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM accessRule_privilege WHERE accessRule_id = @authHpdsIngress);
