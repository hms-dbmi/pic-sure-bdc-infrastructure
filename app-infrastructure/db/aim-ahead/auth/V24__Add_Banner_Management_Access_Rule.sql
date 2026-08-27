use auth;

SET @bannerManagementGateway = unhex(REPLACE(UUID(),'-',''));
SET @bannerManagementPrivilege = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @bannerManagementGateway, 'AR_BANNER_MANAGEMENT_GATEWAY',
    'Allow the banner management privilege through the gateway operations path',
    '$.[\'Target Service\']', 11, '^/operations/banners/?$', 0x00, 0x00, NULL, 0x00, 0x00
);

INSERT INTO privilege (uuid, name, description, application_id, queryScope)
VALUES (
    @bannerManagementPrivilege, 'BANNER_MANAGEMENT', 'Allow site banner publication',
    (SELECT uuid FROM application WHERE name = 'PICSURE'), '[]'
);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
VALUES (@bannerManagementPrivilege, @bannerManagementGateway);

INSERT INTO role_privilege (role_id, privilege_id)
SELECT uuid, @bannerManagementPrivilege
FROM role
WHERE name IN ('Admin', 'PIC-SURE Top Admin');
