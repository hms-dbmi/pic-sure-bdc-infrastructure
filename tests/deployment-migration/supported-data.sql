SET @preservedRole = UUID_TO_BIN('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
SET @preservedPrivilege = UUID_TO_BIN('dddddddd-dddd-dddd-dddd-dddddddddddd');
SET @preservedAccessRule = UUID_TO_BIN('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee');

INSERT INTO auth.role (uuid, name, description)
VALUES (
    @preservedRole,
    'Synthetic preserved role',
    'Synthetic deployment migration proof row'
);

INSERT INTO auth.privilege (uuid, description, name, application_id, queryTemplate, queryScope)
VALUES (
    @preservedPrivilege,
    'Synthetic preserved privilege',
    'SYNTHETIC_PRESERVED_PRIVILEGE',
    (SELECT uuid FROM auth.application WHERE name = 'PICSURE'),
    'synthetic-template',
    '["synthetic"]'
);

INSERT INTO auth.access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
) VALUES (
    @preservedAccessRule,
    'AR_SYNTHETIC_PRESERVED',
    'Synthetic preserved access rule',
    'synthetic-rule',
    99,
    'synthetic-value',
    0x00,
    0x00,
    NULL,
    0x00,
    0x00
);

INSERT INTO auth.accessRule_privilege (privilege_id, accessRule_id)
VALUES (@preservedPrivilege, @preservedAccessRule);

INSERT INTO auth.role_privilege (role_id, privilege_id)
VALUES (@preservedRole, @preservedPrivilege);

INSERT INTO picsure.user (uuid, roles, subject, userId)
VALUES (
    UUID_TO_BIN('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
    'SYNTHETIC',
    'synthetic-banner-proof',
    'preserve-me'
);
