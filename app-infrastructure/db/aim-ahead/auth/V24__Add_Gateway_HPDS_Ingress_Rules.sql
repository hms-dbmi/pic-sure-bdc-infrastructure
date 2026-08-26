use auth;

-- AIM-AHEAD has no gateway path rule for HPDS open access, so create both
-- backend-specific route grants.
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
