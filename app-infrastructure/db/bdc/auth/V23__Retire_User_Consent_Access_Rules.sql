use auth;

DELETE arp
FROM accessRule_privilege arp
JOIN access_rule retired ON retired.uuid = arp.accessRule_id
WHERE retired.type = 17;

DELETE arg
FROM accessRule_gate arg
JOIN access_rule retired ON retired.uuid = arg.gate_id
WHERE retired.type = 17;

DELETE arg
FROM accessRule_gate arg
JOIN access_rule retired ON retired.uuid = arg.accessRule_id
WHERE retired.type = 17;

DELETE asr
FROM accessRule_subRule asr
JOIN access_rule retired ON retired.uuid = asr.subRule_id
WHERE retired.type = 17;

DELETE asr
FROM accessRule_subRule asr
JOIN access_rule retired ON retired.uuid = asr.accessRule_id
WHERE retired.type = 17;

UPDATE access_rule child
JOIN access_rule retired ON retired.uuid = child.subAccessRuleParent_uuid
SET child.subAccessRuleParent_uuid = NULL
WHERE retired.type = 17;

DELETE FROM access_rule
WHERE type = 17;
