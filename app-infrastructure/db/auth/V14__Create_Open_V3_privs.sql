SET
@uuidAR_OPEN_QUERIES = REPLACE('ac004461-1b47-4832-80e2-22a4aecabe39', '-', '');

INSERT INTO access_rule
VALUES (unhex(@uuidAR_OPEN_QUERIES),
        'AR_ALLOW_OPEN_ACCESS_V3',
        'allow access to open hpds resource',
        '$.query.resourceUUID',
        9,
        '70c837be-5ffc-11eb-ae93-0242ac130002',
        0,
        0,
        NULL,
        0,
        0);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
VALUES ((select uuid from privilege where name = 'MANAGED_PRIV_OPEN_ACCESS'),
        unhex(@uuidAR_OPEN_QUERIES));