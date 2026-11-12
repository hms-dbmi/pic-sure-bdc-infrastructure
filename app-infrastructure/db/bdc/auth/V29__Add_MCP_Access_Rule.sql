-- PIC_SURE_MCP lets a caller's own agent read counts and dictionary data through /mcp, outside the assistant, so it is
-- granted deliberately and not to every user: only Admin and PIC-SURE Top Admin hold it. Grant it to any other role that
-- should reach MCP. The open-access role never holds it, and pic-sure-mcp refuses open-access callers regardless.
-- pic-sure-ai-service's own /mcp calls do not need it; the gateway authorizes them against the assistant's rule
-- (AR_AI_SERVICE_CALLER, ASSISTED_SEARCH, V30) when it verifies the AI service token.
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
    UNHEX(REPLACE('3b6f0c5e-8d2a-4e71-9a4c-5f1d7e2b9c30', '-', '')),
    'AR_MCP_REQUESTS',
    'Permit requests to the MCP endpoint',
    '$.[\'Target Service\']', 11, '^/mcp$',
    0x00, 0x00, NULL, 0x00, 0x00
WHERE NOT EXISTS (SELECT 1 FROM access_rule WHERE name = 'AR_MCP_REQUESTS');

INSERT INTO privilege (uuid, name, description, application_id, queryScope)
SELECT
    UNHEX(REPLACE('a17c4e92-6b03-4d58-8e2f-0c9b3d6f1a74', '-', '')),
    'PIC_SURE_MCP',
    'Allow access to the MCP endpoint',
    (SELECT uuid FROM application WHERE name = 'PICSURE'),
    '[]'
WHERE NOT EXISTS (SELECT 1 FROM privilege WHERE name = 'PIC_SURE_MCP');

SET @mcpPrivilege = (SELECT uuid FROM privilege WHERE name = 'PIC_SURE_MCP');

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT @mcpPrivilege, access_rule.uuid
FROM access_rule
WHERE access_rule.name = 'AR_MCP_REQUESTS'
AND NOT EXISTS (
    SELECT 1
    FROM accessRule_privilege existing
    WHERE existing.privilege_id = @mcpPrivilege
      AND existing.accessRule_id = access_rule.uuid
);

INSERT INTO role_privilege (role_id, privilege_id)
SELECT role.uuid, @mcpPrivilege
FROM role
WHERE role.name IN ('Admin', 'PIC-SURE Top Admin')
AND NOT EXISTS (
    SELECT 1
    FROM role_privilege existing
    WHERE existing.role_id = role.uuid
      AND existing.privilege_id = @mcpPrivilege
);
