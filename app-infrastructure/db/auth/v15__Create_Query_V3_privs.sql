
SET @uuidAuthRole = REPLACE(UUID(),'-','');
insert into role(uuid, name, description)
values (unhex(@uuidAuthRole),
        'MANUAL_ROLE_AUTH_ACCESS',
        'This role will allow users to query auth HPDS based on their consents');

SET @uuidAuthPriv = REPLACE(UUID(),'-','');
INSERT INTO privilege (uuid, name, description, application_id, queryScope)
VALUES (unhex(@uuidAuthPriv),
        'MANAGED_PRIV_AUTH_ACCESS',
        'Allow access to queries for AUTH PICSURE',
        (SELECT uuid FROM application WHERE name = 'PICSURE'),
        '[]');

SET @uuidGateQuery = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuidGateQuery),
        'GATE_QUERY_v3',
        'triggers if user submits a V3 query',
        '$.[\'Target Service\']',
        17,
        '/v3/query',
        0,
        0,
        NULL,
        0,
        0);


INSERT INTO role_privilege (role_id, privilege_id)
VALUES (unhex(@uuidAuthRole),
        unhex(@uuidAuthPriv));

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
values (unhex(@uuidAuthPriv),
        unhex(@uuidGateQuery));