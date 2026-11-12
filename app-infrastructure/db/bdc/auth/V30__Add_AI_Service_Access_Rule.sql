-- ASSISTED_SEARCH gates pic-sure-ai-service's chat endpoints, and the gateway also authorizes the assistant's own /mcp calls
-- against AR_AI_SERVICE_CALLER (the gateway sends Caller = ai-service) when it verifies the AI service token. Only Admin and
-- PIC-SURE Top Admin hold it here; grant it to any other role that should use the assistant.
--
-- Rollout requirement: PSAMA caches merged access rules per user and application in `mergedRulesCache` and
-- `preProcessedAccessRules`, so on an existing install the new privilege attachment is not visible to
-- already-cached sessions. Restart the PSAMA instances or evict both caches after this migration runs.
use auth;

INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT
    UNHEX(REPLACE('5c92234d-e3e1-428c-8c4c-eba6b725d53a', '-', '')),
    'AR_AI_SERVICE_REQUESTS',
    'Permit requests to the AI-Service endpoint',
    '$.[\'Target Service\']', 11, '^/ai(/.*)?$',
    0x00, 0x00, NULL, 0x00, 0x00
WHERE NOT EXISTS (SELECT 1 FROM access_rule WHERE name = 'AR_AI_SERVICE_REQUESTS');

INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT
    UNHEX(REPLACE('0b6f5c1e-7a3d-4e52-9c18-3f4d2a8e6b97', '-', '')),
    'AR_AI_SERVICE_CALLER',
    'Permit the AI service to call /mcp on a user''s behalf; gated on AR_MCP_REQUESTS so it covers only /mcp',
    '$.[\'Caller\']', 11, '^ai-service$',
    0x00, 0x00, NULL, 0x00, 0x00
WHERE NOT EXISTS (SELECT 1 FROM access_rule WHERE name = 'AR_AI_SERVICE_CALLER');

INSERT INTO privilege (uuid, name, description, application_id, queryScope)
SELECT
    UNHEX(REPLACE('d9aaa1b4-0115-45f3-b594-70ff9d7da702', '-', '')),
    'ASSISTED_SEARCH',
    'Allow access to the AI-Service endpoint',
    (SELECT uuid FROM application WHERE name = 'PICSURE'),
    '[]'
WHERE NOT EXISTS (SELECT 1 FROM privilege WHERE name = 'ASSISTED_SEARCH');

SET @aisPrivilege = (SELECT uuid FROM privilege WHERE name = 'ASSISTED_SEARCH');

-- AR_AI_SERVICE_CALLER passes only for a /mcp request: AR_MCP_REQUESTS is its gate, so a Caller of ai-service does not authorize
-- any other path. AR_MCP_REQUESTS is created by the MCP access rule migration, which runs before this one. A rule with no gate would
-- pass for any path, so the rule is attached to ASSISTED_SEARCH only once it has its gate: if AR_MCP_REQUESTS is missing, the
-- assistant's /mcp calls are denied and not over-authorized.
INSERT INTO accessRule_gate (accessRule_id, gate_id)
SELECT caller.uuid, mcp.uuid
FROM access_rule caller
JOIN access_rule mcp ON mcp.name = 'AR_MCP_REQUESTS'
WHERE caller.name = 'AR_AI_SERVICE_CALLER'
AND NOT EXISTS (
    SELECT 1
    FROM accessRule_gate existing
    WHERE existing.accessRule_id = caller.uuid
      AND existing.gate_id = mcp.uuid
);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT @aisPrivilege, access_rule.uuid
FROM access_rule
WHERE (
    access_rule.name = 'AR_AI_SERVICE_REQUESTS'
    OR (
        access_rule.name = 'AR_AI_SERVICE_CALLER'
        AND EXISTS (SELECT 1 FROM accessRule_gate gated WHERE gated.accessRule_id = access_rule.uuid)
    )
)
AND NOT EXISTS (
    SELECT 1
    FROM accessRule_privilege existing
    WHERE existing.privilege_id = @aisPrivilege
      AND existing.accessRule_id = access_rule.uuid
);

INSERT INTO role_privilege (role_id, privilege_id)
SELECT role.uuid, @aisPrivilege
FROM role
WHERE role.name IN ('Admin', 'PIC-SURE Top Admin')
AND NOT EXISTS (
    SELECT 1
    FROM role_privilege existing
    WHERE existing.role_id = role.uuid
      AND existing.privilege_id = @aisPrivilege
);
