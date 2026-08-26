use auth;

-- Expand the existing gateway open-query rule to every HPDS open path. Its
-- existing privilege attachment remains unchanged.
UPDATE access_rule
SET name = 'AR_ALLOW_HPDS_OPEN_INGRESS',
    description = 'Allow access to the open HPDS backend through the gateway',
    rule = '$.[\'Target Service\']',
    type = 11,
    value = '^/hpds/open(/.*)?$',
    checkMapKeyOnly = 0x00,
    checkMapNode = 0x00,
    subAccessRuleParent_uuid = NULL,
    isGateAnyRelation = 0x00,
    isEvaluateOnlyByGates = 0x00
WHERE name = 'AR_ALLOW_OPEN_ACCESS_V3_GATEWAY';

-- Authenticated users receive MANAGED_PRIV_AUTH_ACCESS as a baseline
-- privilege. This rule supplies the route grant that remains after consent
-- rule type 17 is retired.
SET @authHpdsIngress = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @authHpdsIngress, 'AR_ALLOW_HPDS_AUTH_INGRESS',
    'Allow access to the authorized HPDS backend through the gateway',
    '$.[\'Target Service\']', 11, '^/hpds/auth(/.*)?$', 0x00, 0x00, NULL, 0x00, 0x00
);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT uuid, @authHpdsIngress
FROM privilege
WHERE name = 'MANAGED_PRIV_AUTH_ACCESS';
