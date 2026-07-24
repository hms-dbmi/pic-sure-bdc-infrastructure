-- Additive gateway-path open-access rule for HPDS open v3 queries.
--
-- The legacy open-access grant AR_ALLOW_OPEN_ACCESS_V3 (V14) authorizes by
-- resourceUUID ($.query.resourceUUID == the open HPDS resource UUID). Under the
-- gateway the query-service selects the backend from the PATH (/hpds/open/...)
-- and resourceUUID is vestigial, so the rewrite frontend sends it empty. The
-- open-access validate (/auth/open/validate -> OpenAccessFilter) therefore
-- evaluates AR_ALLOW_OPEN_ACCESS_V3 against an empty resourceUUID, the rule
-- fails ("Rule check failed: $.query.resourceUUID"), and every anonymous open
-- query is denied 401 "User is not authorized.".
--
-- This adds a path-based sibling that grants open access by Target Service, the
-- same clean-prefix approach V19 used for dictionary/logging/visualization.
-- Scoped to the open v3 query lifecycle (sync/async/result/status/signed-url),
-- which the query-service only ever routes to the open (obfuscated) backend, so
-- it cannot reach auth data. The legacy resourceUUID rule is RETAINED for
-- WildFly until cutover. Privilege and gate attachments are copied from the
-- legacy rule at migration time so UI-managed attachments carry over per
-- environment (same pattern as V19/V20).

use auth;

SET @openQueryGateway = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @openQueryGateway, 'AR_ALLOW_OPEN_ACCESS_V3_GATEWAY',
    'Allow open access to open HPDS v3 queries via the gateway open path',
    '$.[\'Target Service\']', 11, '^/hpds/open/v3/query(/.*)?$', 0x00, 0x00, NULL, 0x00, 0x00
);

-- Mirror the legacy rule's privilege attachments (V14 attaches it to
-- MANAGED_PRIV_OPEN_ACCESS; copy whatever this environment actually has).
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT arp.privilege_id, @openQueryGateway
FROM accessRule_privilege arp
JOIN access_rule legacy ON arp.accessRule_id = legacy.uuid
WHERE legacy.name = 'AR_ALLOW_OPEN_ACCESS_V3';

-- Mirror gate attachments too. V14 defines none, but if an environment gated
-- the legacy rule via the UI, the gateway sibling must be gated identically.
INSERT INTO accessRule_gate (gate_id, accessRule_id)
SELECT ag.gate_id, @openQueryGateway
FROM accessRule_gate ag
JOIN access_rule legacy ON ag.accessRule_id = legacy.uuid
WHERE legacy.name = 'AR_ALLOW_OPEN_ACCESS_V3';
