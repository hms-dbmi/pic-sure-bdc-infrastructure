-- Gateway clean-prefix access rules for the dictionary and visualization routes.
--
-- The gateway strips the /proxy/<container> segment before forwarding, but it
-- introspects with the pre-strip public path, so PSAMA sees Target Service =
-- /dictionary/... and /visualization/... where WildFly saw
-- /proxy/dictionary-api/... . The legacy /proxy rules are RETAINED: live prod
-- runs WildFly until cutover.
--
-- Each rule names the privileges it attaches to. The earlier version of this
-- file copied whatever attachments the legacy sibling happened to hold, which
-- is not deterministic for the dictionary rule: V11 creates
-- AR_DICTIONARY_REQUESTS with no attachment at all, and the only thing that
-- binds it to a privilege is PrivilegeService.updateAllPrivilegesOnStartup().
-- A copy therefore picks up every privilege in an environment where PSAMA has
-- already booted, and nothing at all in a fresh one, where the result is a
-- silent denial of every /dictionary request.
--
-- No rule is created for /logging. That prefix is on the gateway's
-- allow-list-prefixes, so it is never introspected and an access rule for it
-- would never be evaluated.

use auth;

-- ---- /dictionary ------------------------------------------------------------

SET @dictCleanPrefix = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @dictCleanPrefix, 'AR_DICTIONARY_CLEAN_PREFIX',
    'Permit requests to dictionary endpoints via the gateway clean-prefix path',
    '$.[\'Target Service\']', 11, '^/dictionary(/.*)?$', 0x00, 0x00, NULL, 0x00, 0x00
);

-- MANAGED_PRIV_DICTIONARY is the privilege whose purpose this is;
-- MANAGED_PRIV_OPEN_ACCESS carries it for the anonymous open-access path, which
-- evaluates the privileges of MANUAL_ROLE_OPEN_ACCESS only.
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT uuid, @dictCleanPrefix
FROM privilege
WHERE name IN ('MANAGED_PRIV_DICTIONARY', 'MANAGED_PRIV_OPEN_ACCESS');

-- Fail the migration if that matched nothing. An access rule with no privilege
-- is never evaluated, so a renamed or missing privilege would ship as a silent
-- denial rather than an error. Signal by duplicating the rule's own primary
-- key, which errors 1062 in every sql_mode, strict or not. The DML in this file
-- is transactional: on failure nothing half-applies.
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT @dictCleanPrefix, 'MIGRATION_GUARD_UNATTACHED_RULE',
       'MIGRATION GUARD: AR_DICTIONARY_CLEAN_PREFIX matched no privilege',
       '', 0, '', 0x00, 0x00, NULL, 0x00, 0x00
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM accessRule_privilege WHERE accessRule_id = @dictCleanPrefix);

-- ---- /visualization ---------------------------------------------------------

SET @vizCleanPrefix = unhex(REPLACE(UUID(),'-',''));
INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @vizCleanPrefix, 'AR_VISUALIZATION_CLEAN_PREFIX',
    'Permit requests to visualization endpoints via the gateway clean-prefix path',
    '$.[\'Target Service\']', 11, '^/visualization(/.*)?$', 0x00, 0x00, NULL, 0x00, 0x00
);

-- One rule rather than a per-backend split: /visualization/bin/continuous,
-- /visualization/info and /visualization/query/format are backend-agnostic, and
-- the two that are not (/visualization/{auth,open}/distributions) are already
-- separated twice over. Anonymous callers cannot reach /visualization/auth/**
-- (AuthorizationService.isAuthTargetService refuses it in code), and an
-- authenticated caller's distributions request is forwarded to the query
-- service with their own bearer token, so consent scoping applies there.
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT uuid, @vizCleanPrefix
FROM privilege
WHERE name = 'MANAGED_PRIV_OPEN_ACCESS';

INSERT INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)
SELECT @vizCleanPrefix, 'MIGRATION_GUARD_UNATTACHED_RULE',
       'MIGRATION GUARD: AR_VISUALIZATION_CLEAN_PREFIX matched no privilege',
       '', 0, '', 0x00, 0x00, NULL, 0x00, 0x00
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM accessRule_privilege WHERE accessRule_id = @vizCleanPrefix);
