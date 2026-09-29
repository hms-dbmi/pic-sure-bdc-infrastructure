-- Rollout requirement: PSAMA caches merged access rules per user and application in `mergedRulesCache` and
-- `preProcessedAccessRules`, so on an existing install the new privilege attachment is not visible to
-- already-cached sessions. Restart the PSAMA instances or evict both caches after this migration runs.
--
-- Lets PSAMA authorize the MCP endpoint the gateway serves at /mcp. PSAMA denies any path that no access rule
-- matches, so without this rule every /mcp request is refused. The rule only admits the path; data
-- authorization for the tools behind it stays with PSAMA's existing rules.
--
-- The migration fails on purpose if any listed role is missing and so did not receive the privilege. A renamed
-- role would otherwise ship as a silent denial for its users. The failure duplicates the rule's own
-- primary key, which errors 1062 in every sql_mode, and nothing half-applies.
use auth;

SET @mcpRequests = unhex(REPLACE(UUID(),'-',''));
SET @mcpPrivilege = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @mcpRequests, 'AR_MCP_REQUESTS',
    'Permit requests to the MCP endpoint through the gateway',
    '$.[\'Target Service\']', 11, '^/mcp$', 0x00, 0x00, NULL, 0x00, 0x00
);

INSERT INTO privilege (uuid, name, description, application_id, queryScope)
VALUES (
    @mcpPrivilege, 'PIC_SURE_MCP', 'Allow access to the PIC-SURE MCP endpoint',
    (SELECT uuid FROM application WHERE name = 'PICSURE'), '[]'
);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
VALUES (@mcpPrivilege, @mcpRequests);

INSERT INTO role_privilege (role_id, privilege_id)
SELECT uuid, @mcpPrivilege
FROM role
WHERE CAST(name AS BINARY) IN ('MANUAL_ROLE_OPEN_ACCESS', 'MANUAL_ROLE_AUTH_ACCESS', 'MANUAL_ROLE_NAMED_DATASET', 'Admin', 'PIC-SURE Top Admin');

INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT @mcpRequests, 'MIGRATION_GUARD_UNATTACHED_RULE',
       'MIGRATION GUARD: PIC_SURE_MCP was not granted to every listed role',
       '', 0, '', 0x00, 0x00, NULL, 0x00, 0x00
FROM dual
WHERE (
    SELECT COUNT(DISTINCT CAST(r.name AS BINARY))
    FROM role_privilege rp JOIN role r ON r.uuid = rp.role_id
    WHERE rp.privilege_id = @mcpPrivilege
      AND CAST(r.name AS BINARY) IN ('MANUAL_ROLE_OPEN_ACCESS', 'MANUAL_ROLE_AUTH_ACCESS', 'MANUAL_ROLE_NAMED_DATASET', 'Admin', 'PIC-SURE Top Admin')
) < 5;
