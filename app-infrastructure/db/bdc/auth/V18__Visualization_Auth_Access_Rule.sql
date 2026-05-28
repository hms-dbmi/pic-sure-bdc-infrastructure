SET @allowVisualizationRequests = unhex(REPLACE(UUID(),'-',''));

INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT
    @allowVisualizationRequests, 'AR_VISUALIZATION_PROXY_REQUESTS', 'Permit requests to visualization endpoints',
    '$.[\'Target Service\']', 11, '^/?proxy/visualization/.*$',
    0x00, 0x00, NULL, 0x00, 0x00
WHERE NOT EXISTS (
    SELECT 1 FROM access_rule WHERE name = 'AR_VISUALIZATION_PROXY_REQUESTS'
);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT privilege.uuid, access_rule.uuid
FROM privilege, access_rule
WHERE privilege.name = 'MANAGED_PRIV_OPEN_ACCESS'
  AND access_rule.name = 'AR_VISUALIZATION_PROXY_REQUESTS'
  AND NOT EXISTS (
      SELECT 1
      FROM accessRule_privilege existing
      WHERE existing.privilege_id = privilege.uuid
        AND existing.accessRule_id = access_rule.uuid
  );
