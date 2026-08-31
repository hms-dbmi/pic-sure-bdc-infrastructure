-- Gateway-path sibling of AR_NAMED_DATASET (V9). The V9 rule kept the
-- WildFly-era path (^/dataset/named...), but the gateway introspects with the
-- pre-strip public path, so Managed Datasets requests arrive at PSAMA as
-- Target Service = /operations/dataset/named and are denied. The legacy rule is
-- RETAINED for WildFly until cutover.
--
-- The rule's attributes and its privileges are stated here rather than copied
-- from the legacy row, for the same reason as V22: a migration should produce
-- the same result in a fresh environment as in one that has been running for a
-- year. checkMapNode stays 1 to match V9 exactly.

use auth;

SET @namedDatasetGateway = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @namedDatasetGateway, 'AR_NAMED_DATASET_GATEWAY',
    'Allow access to named dataset via the gateway operations path',
    '$.[\'Target Service\']', 11,
    '^/operations/dataset/named(/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}))?$',
    0x00, 0x01, NULL, 0x00, 0x00
);

-- Both privileges V9 attaches the legacy rule to. MANUAL_PRIV_METADATA_ACCESS
-- belongs to no role and so grants nobody anything today; it is kept so the two
-- rules stay interchangeable through the cutover.
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT uuid, @namedDatasetGateway
FROM privilege
WHERE name IN ('MANUAL_PRIV_NAMED_DATASET', 'MANUAL_PRIV_METADATA_ACCESS');

-- Fail the migration if that matched nothing (see V22 for the mechanism).
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT @namedDatasetGateway, 'MIGRATION_GUARD_UNATTACHED_RULE',
       'MIGRATION GUARD: AR_NAMED_DATASET_GATEWAY matched no privilege',
       '', 0, '', 0x00, 0x00, NULL, 0x00, 0x00
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM accessRule_privilege WHERE accessRule_id = @namedDatasetGateway);
