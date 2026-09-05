-- Rollout requirement: PSAMA caches merged access rules per user and application in `mergedRulesCache` and
-- `preProcessedAccessRules`, so on an existing install the new privilege attachment is not visible to
-- already-cached sessions. Restart the PSAMA instances or evict both caches after this migration runs.
use auth;

SET @bannerManagementGateway = unhex(REPLACE(UUID(),'-',''));
SET @bannerManagementPrivilege = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @bannerManagementGateway, 'AR_BANNER_MANAGEMENT_GATEWAY',
    'Allow the banner management privilege through explicit gateway operations routes',
    '$.[\'Target Service\']', 11, '^/operations/banners(?:/?|/saved/?|/order/?|/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(?:/?|/publish/?|/disable/?|/archive/?|/restore/?))$', 0x00, 0x00, NULL, 0x00, 0x00
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
