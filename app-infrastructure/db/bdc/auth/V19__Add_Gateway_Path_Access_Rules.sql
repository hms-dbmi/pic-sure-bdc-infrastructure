-- Additive gateway clean-prefix and /hpds/{auth,open}/v3 access rules.
-- Legacy /proxy and /v3 rules are RETAINED: live prod runs WildFly until cutover.
-- New rules copy privilege/gate attachments from their legacy siblings at
-- migration time, so UI-managed attachments carry over per environment.

use auth;

-- ---- Clean-prefix siblings (gateway drops the /proxy/<container> segment) ----

SET @dictCleanPrefix = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @dictCleanPrefix, 'AR_DICTIONARY_CLEAN_PREFIX',
    'Permit requests to dictionary endpoints via the gateway clean-prefix path',
    '$.[\'Target Service\']', 11, '^/dictionary(/.*)?$', 0x00, 0x00, NULL, 0x00, 0x00
);
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT arp.privilege_id, @dictCleanPrefix
FROM accessRule_privilege arp
JOIN access_rule legacy ON arp.accessRule_id = legacy.uuid
WHERE legacy.name = 'AR_DICTIONARY_REQUESTS';

SET @loggingCleanPrefix = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @loggingCleanPrefix, 'AR_LOGGING_CLEAN_PREFIX',
    'Permit requests to logging endpoints via the gateway clean-prefix path',
    '$.[\'Target Service\']', 11, '^/logging(/.*)?$', 0x00, 0x00, NULL, 0x00, 0x00
);
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT arp.privilege_id, @loggingCleanPrefix
FROM accessRule_privilege arp
JOIN access_rule legacy ON arp.accessRule_id = legacy.uuid
WHERE legacy.name = 'AR_LOGGING_REQUESTS';

SET @vizCleanPrefix = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @vizCleanPrefix, 'AR_VISUALIZATION_CLEAN_PREFIX',
    'Permit requests to visualization endpoints via the gateway clean-prefix path',
    '$.[\'Target Service\']', 11, '^/visualization(/.*)?$', 0x00, 0x00, NULL, 0x00, 0x00
);
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT arp.privilege_id, @vizCleanPrefix
FROM accessRule_privilege arp
JOIN access_rule legacy ON arp.accessRule_id = legacy.uuid
WHERE legacy.name = 'AR_VISUALIZATION_PROXY_REQUESTS';

-- ---- /hpds/{auth,open}/v3 gate siblings of GATE_QUERY_v3 --------------------

-- Fail loudly if any rule is ALL-gated on GATE_QUERY_v3: adding a second path
-- gate to an ALL-gate parent would silently break it. Signal by violating the
-- primary key constraint — duplicate of GATE_QUERY_v3's own uuid — which
-- errors 1062 in every sql_mode, strict or not (error aborts the migration;
-- on failure inspect the parent rules with George before re-running — the
-- DML in this file is transactional, nothing half-applies).
INSERT INTO access_rule (uuid, name, description, rule, type, value,
    checkMapKeyOnly, checkMapNode, subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates)
SELECT gate.uuid, 'MIGRATION_GUARD_ALL_GATED_V3_PARENT',
       'MIGRATION GUARD: ALL-gated parent of GATE_QUERY_v3 found — manual review required',
       '', 0, '', 0x00, 0x00, NULL, 0x00, 0x00
FROM accessRule_gate ag
JOIN access_rule gate ON ag.gate_id = gate.uuid AND gate.name = 'GATE_QUERY_v3'
JOIN access_rule parent ON ag.accessRule_id = parent.uuid
WHERE parent.isGateAnyRelation = 0
LIMIT 1;

SET @gateHpdsAuthV3 = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT @gateHpdsAuthV3, 'GATE_QUERY_HPDS_AUTH_V3',
       'triggers if user submits a V3 query via the gateway auth path',
       g.rule, g.type, '/hpds/auth/v3/query', g.checkMapKeyOnly, g.checkMapNode,
       g.subAccessRuleParent_uuid, g.isGateAnyRelation, g.isEvaluateOnlyByGates
FROM access_rule g WHERE g.name = 'GATE_QUERY_v3';

SET @gateHpdsOpenV3 = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT @gateHpdsOpenV3, 'GATE_QUERY_HPDS_OPEN_V3',
       'triggers if user submits a V3 query via the gateway open path',
       g.rule, g.type, '/hpds/open/v3/query', g.checkMapKeyOnly, g.checkMapNode,
       g.subAccessRuleParent_uuid, g.isGateAnyRelation, g.isEvaluateOnlyByGates
FROM access_rule g WHERE g.name = 'GATE_QUERY_v3';

-- Attach the new gates everywhere GATE_QUERY_v3 gates an ANY-relation rule.
INSERT INTO accessRule_gate (gate_id, accessRule_id)
SELECT @gateHpdsAuthV3, ag.accessRule_id
FROM accessRule_gate ag
JOIN access_rule gate ON ag.gate_id = gate.uuid AND gate.name = 'GATE_QUERY_v3'
JOIN access_rule parent ON ag.accessRule_id = parent.uuid
WHERE parent.isGateAnyRelation = 1;

INSERT INTO accessRule_gate (gate_id, accessRule_id)
SELECT @gateHpdsOpenV3, ag.accessRule_id
FROM accessRule_gate ag
JOIN access_rule gate ON ag.gate_id = gate.uuid AND gate.name = 'GATE_QUERY_v3'
JOIN access_rule parent ON ag.accessRule_id = parent.uuid
WHERE parent.isGateAnyRelation = 1;

-- Mirror privilege attachments of the legacy v3 gate rule (it is attached as a
-- rule to MANAGED_PRIV_AUTH_ACCESS in V15; copy whatever this environment has).
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT arp.privilege_id, @gateHpdsAuthV3
FROM accessRule_privilege arp
JOIN access_rule legacy ON arp.accessRule_id = legacy.uuid
WHERE legacy.name = 'GATE_QUERY_v3';

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT arp.privilege_id, @gateHpdsOpenV3
FROM accessRule_privilege arp
JOIN access_rule legacy ON arp.accessRule_id = legacy.uuid
WHERE legacy.name = 'GATE_QUERY_v3';
