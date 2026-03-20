SET @uuidAR_ALLOW_STAT = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuidAR_ALLOW_STAT),
        'AR_ALLOW_STAT_VIS',
        'allow access to stat vis resource',
        '$.query.resourceUUID',
        9,
        'ca0ad4a9-130a-3a8a-ae00-e35b07f1108b',
        0,
        0,
        NULL,
        0,
        0);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
VALUES ((SELECT uuid FROM privilege WHERE name = 'MANAGED_PRIV_OPEN_ACCESS'),
        unhex(@uuidAR_ALLOW_STAT));