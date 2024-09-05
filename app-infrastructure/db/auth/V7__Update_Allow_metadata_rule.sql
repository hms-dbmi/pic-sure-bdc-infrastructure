-- Update the access rule for metadata access to use the 'Target Service' field instead of 'path'
UPDATE access_rule
SET rule = '$.path', type = 11, checkMapKeyOnly = 0, value = '^/query/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})/metadata$'
    checkMapNode = 0, isEvaluateOnlyByGates = 0, isGateAnyRelation = 0, name = 'AR_ALLOW_METADATA_ACCESS'
WHERE name = 'ALLOW_METADATA_ACCESS';

-- update the MANAGED_ROLE_OPEN_ACCESS and change it to MANUAL_ROLE_OPEN_ACCESS
UPDATE role
SET name = 'MANUAL_ROLE_OPEN_ACCESS'
WHERE name = 'MANAGED_ROLE_OPEN_ACCESS';

-- Allow named dataset access
/*
Regular Expression Description:
^: Asserts the start of the string.
/dataset/named: Matches the literal path '/dataset/named'.
(/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}))?: Matches either:
    /: A literal forward slash (optional).
    ([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}): A valid UUID.
    ?: Makes the entire UUID pattern, including the preceding '/', optional.
$: Asserts the end of the string.
*/

SET @uuidAR_NAMED_DATASET = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuidAR_NAMED_DATASET),
        'AR_NAMED_DATASET',
        'Allow access to named dataset',
        '$.[\'Target Service\']',
        4,
        '^/dataset/named/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})?$',
        0,
        1,
        NULL,
        0,
        1);

-- Create a privilege for metadata access
SET @uuidPriv = REPLACE(UUID(),'-','');
INSERT INTO privilege (uuid, name, description, application_id, queryScope)
VALUES (unhex(@uuidPriv),
        'MANUAL_PRIV_METADATA_ACCESS',
        'Allow access to metadata endpoint',
        (SELECT uuid FROM application WHERE name = 'PICSURE'),
        '[]');

-- Associate the metadata access rule with the metadata access privilege
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
VALUES (unhex(@uuidPriv),
        unhex(@uuidAR_NAMED_DATASET));

-- Create a privilege for named dataset access
SET @uuidPriv = REPLACE(UUID(),'-','');
INSERT INTO privilege (uuid, name, description, application_id, queryScope)
VALUES (unhex(@uuidPriv),
        'MANUAL_PRIV_NAMED_DATASET',
        'Allow access to named dataset',
        (SELECT uuid FROM application WHERE name = 'PICSURE'),
        '[]');

-- Associate the named dataset access rule with the named dataset privilege
INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
VALUES (unhex(@uuidPriv),
        unhex(@uuidAR_NAMED_DATASET));

-- Create a role for named dataset access
SET @uuidRole = REPLACE(UUID(),'-','');
INSERT INTO role
VALUES (unhex(@uuidRole),
        'MANUAL_ROLE_NAMED_DATASET',
        'This role will allow users to log in and query named datasets');

-- associate the metadata access privilege with the named dataset role
INSERT INTO role_privilege (role_id, privilege_id)
VALUES (unhex(@uuidRole),
        (SELECT uuid FROM privilege WHERE name = 'MANUAL_PRIV_NAMED_DATASET'));