use auth;

DELETE arp
FROM accessRule_privilege arp
JOIN access_rule consent_rule ON consent_rule.uuid = arp.accessRule_id
WHERE consent_rule.type = 17;

DELETE arg
FROM accessRule_gate arg
JOIN access_rule consent_rule ON consent_rule.uuid = arg.gate_id
WHERE consent_rule.type = 17;

DELETE arg
FROM accessRule_gate arg
JOIN access_rule consent_rule ON consent_rule.uuid = arg.accessRule_id
WHERE consent_rule.type = 17;

DELETE asr
FROM accessRule_subRule asr
JOIN access_rule consent_rule ON consent_rule.uuid = asr.subRule_id
WHERE consent_rule.type = 17;

DELETE asr
FROM accessRule_subRule asr
JOIN access_rule consent_rule ON consent_rule.uuid = asr.accessRule_id
WHERE consent_rule.type = 17;

UPDATE access_rule child
JOIN access_rule consent_rule ON consent_rule.uuid = child.subAccessRuleParent_uuid
SET child.subAccessRuleParent_uuid = NULL
WHERE consent_rule.type = 17;

DELETE FROM access_rule
WHERE type = 17;
