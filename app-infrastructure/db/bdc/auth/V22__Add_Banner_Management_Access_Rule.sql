use auth;

SET @bannerManagementGateway = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @bannerManagementGateway, 'AR_BANNER_MANAGEMENT_GATEWAY',
    'Allow administrators to publish site banners through the gateway operations path',
    '$.[\'Target Service\']', 11, '^/operations/banners/?$', 0x00, 0x00, NULL, 0x00, 0x00
);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT uuid, @bannerManagementGateway
FROM privilege
WHERE name IN ('ADMIN', 'SUPER_ADMIN');
