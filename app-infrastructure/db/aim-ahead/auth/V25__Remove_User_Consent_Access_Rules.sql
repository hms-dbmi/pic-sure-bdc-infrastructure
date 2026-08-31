-- Retire the consent access rule type (17).
--
-- PSAMA no longer implements it: AccessRule.TypeNaming stops at 16, and
-- AccessRuleService._decisionMaker's default branch refuses to grant on a type
-- it does not recognise. A type-17 row left in the table is therefore not
-- inert, it is a rule that can only ever deny -- and the one this schema
-- creates, GATE_QUERY_v3 (V20), hangs off MANAGED_PRIV_AUTH_ACCESS, which every
-- authenticated user holds. V24's AR_ALLOW_HPDS_AUTH_INGRESS is its
-- replacement; the per-study check it used to perform now runs in the HPDS
-- query service, against the caller's consents, on every query and on every
-- read of a stored result.
--
-- The sweep is written against the type rather than against GATE_QUERY_v3 by
-- name because all three join tables carry foreign keys into access_rule, so
-- any type-17 row an environment minted through the admin UI would block the
-- delete and stay behind as a permanent denial.

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
