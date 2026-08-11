-- Additive gateway-path sibling of AR_NAMED_DATASET. The V9 rule kept the
-- WildFly-era path (^/dataset/named...), but the gateway introspects with the
-- pre-strip public path, so Managed Datasets requests arrive at PSAMA as
-- Target Service = /operations/dataset/named and are denied. The legacy rule
-- is RETAINED for WildFly until cutover. The new rule copies the legacy rule's
-- attributes plus its privilege and gate attachments at migration time, so
-- UI-managed attachments carry over per environment (same pattern as V22).

use auth;

SET @namedDatasetGateway = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT @namedDatasetGateway, 'AR_NAMED_DATASET_GATEWAY',
       'Allow access to named dataset via the gateway operations path',
       legacy.rule, legacy.type,
       '^/operations/dataset/named(/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}))?$',
       legacy.checkMapKeyOnly, legacy.checkMapNode, legacy.subAccessRuleParent_uuid,
       legacy.isGateAnyRelation, legacy.isEvaluateOnlyByGates
FROM access_rule legacy
WHERE legacy.name = 'AR_NAMED_DATASET';

-- Mirror the legacy rule's privilege attachments (V9 attaches it to
-- MANUAL_PRIV_METADATA_ACCESS and MANUAL_PRIV_NAMED_DATASET; copy whatever
-- this environment actually has).
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT arp.privilege_id, @namedDatasetGateway
FROM accessRule_privilege arp
JOIN access_rule legacy ON arp.accessRule_id = legacy.uuid
WHERE legacy.name = 'AR_NAMED_DATASET';

-- Mirror gate attachments too. V9 defines none, but if an environment gated
-- the legacy rule via the UI, the gateway sibling must be gated identically.
INSERT INTO accessRule_gate (gate_id, accessRule_id)
SELECT ag.gate_id, @namedDatasetGateway
FROM accessRule_gate ag
JOIN access_rule legacy ON ag.accessRule_id = legacy.uuid
WHERE legacy.name = 'AR_NAMED_DATASET';
