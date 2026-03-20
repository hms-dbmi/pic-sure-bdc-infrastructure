/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

--
-- This file will create a few very basic
-- rules that can be referenced as 'fence_standard_access_rules' in the wildfly config
--

SET
@uuidAR_INFO_COLUMN_LISTING_ALLOWED = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED),
        'AR_INFO_COLUMN_LISTING',
        'allow query to info_column_listing',
        '$.query.query.expectedResultType',
        4,
        'INFO_COLUMN_LISTING',
        0,
        1,
        NULL,
        0,
        0);


SET
@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED),
        'GATE_DONOT_ALLOW_INFO_COLUMN_LISTING',
        'reject info_column_listing query',
        '$.query.query.expectedResultType',
        3,
        'INFO_COLUMN_LISTING',
        0,
        1,
        NULL,
        0,
        0);

SET
@uuidAR_NO_QUERY_ACCESS = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuidAR_NO_QUERY_ACCESS),
        'AR_NO_QUERY_ACCESS',
        'Restrict to any query endpoints',
        '$.[\'Target Service\']',
        1,
        '/query ',
        0,
        0,
        NULL,
        0,
        0);

SET
@uuidGATE_QUERY = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuidGATE_QUERY),
        'GATE_QUERY',
        'triggers if user submits a query',
        '$.[\'Target Service\']',
        6,
        '/query ',
        0,
        0,
        NULL,
        0,
        0);

INSERT INTO accessRule_gate (gate_id, accessRule_id)
VALUES (unhex(@uuidGATE_QUERY),
        unhex(@uuidAR_NO_QUERY_ACCESS));


SET
@uuidAR_ONLY_INFO = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuidAR_ONLY_INFO),
        'AR_ONLY_INFO',
        'Can only do /info',
        '$.[\'Target Service\']',
        6,
        '/info',
        0,
        0,
        NULL,
        0,
        0);

SET
@uuidAR_ONLY_SEARCH = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuidAR_ONLY_SEARCH),
        'AR_ONLY_SEARCH',
        'Can only do /search',
        ' $.[\'Target Service\']',
        6,
        '/search',
        0,
        0,
        NULL,
        0,
        0);

SET
@uuidAR_NO_SEARCH = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuidAR_NO_SEARCH),
        'AR_NO_SEARCH',
        'reject queries for /search',
        ' $.[\'Target Service\']',
        1,
        '/search',
        0,
        0,
        NULL,
        0,
        0);

SET
@uuid_GATE_SEARCH = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuid_GATE_SEARCH),
        'GATE_SEARCH',
        'Triggers on search requests',
        ' $.[\'Target Service\']',
        6,
        '/search',
        0,
        0,
        NULL,
        0,
        0);

INSERT INTO accessRule_gate (gate_id, accessRule_id)
VALUES (unhex(@uuid_GATE_SEARCH),
        unhex(@uuidAR_NO_SEARCH));


-- Add a rule and privilege to allow all queries for open hpds resource.  This must match the ID of the resource
-- specified earlier in this file. (type 9 is ALL_EQUALS_IGNORE_CASE)
--

SET
@uuidAR_OPEN_QUERIES = REPLACE(UUID(),'-','');
INSERT INTO access_rule
VALUES (unhex(@uuidAR_OPEN_QUERIES),
        'AR_ALLOW_OPEN_ACCESS',
        'allow access to open hpds resource',
        '$.query.resourceUUID',
        9,
        '70c837be-5ffc-11eb-ae93-0242ac130002',
        0,
        0,
        NULL,
        0,
        0);


SET
@uuidPriv = REPLACE(UUID(),'-','');
INSERT INTO privilege (uuid, name, description, application_id, queryScope)
VALUES (unhex(@uuidPriv),
        'FENCE_PRIV_OPEN_ACCESS',
        'Allow access to queries for OPEN PICSURE',
        (SELECT uuid FROM application WHERE name = 'PICSURE'),
        '[]');

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
VALUES (unhex(@uuidPriv),
        unhex(@uuidAR_OPEN_QUERIES));

SET
@uuidRole = REPLACE(UUID(),'-','');
INSERT INTO role
VALUES (unhex(@uuidRole),
        'FENCE_ROLE_OPEN_ACCESS',
        'This role will allow users to log in and query OPEN PICSURE');

INSERT INTO role_privilege (role_id, privilege_id)
VALUES (unhex(@uuidRole),
        unhex(@uuidPriv));


INSERT INTO access_rule
VALUES (unhex(REPLACE(UUID(), '-', '')),
        "AR_OPEN_ONLY_SEARCH",
        "Open PIC-SURE Search",
        "$.['Target Service']",
        6,
        "/search/70c837be-5ffc-11eb-ae93-0242ac130002",
        0,
        0,
        NULL,
        0,
        0);

INSERT INTO accessRule_privilege
VALUES ((SELECT uuid FROM privilege WHERE name = 'FENCE_PRIV_OPEN_ACCESS'),
        (SELECT uuid FROM access_rule WHERE name = 'AR_OPEN_ONLY_SEARCH'));

SET
@uuidGate = REPLACE(uuid(),'-','');
INSERT INTO access_rule (uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
                         subAccessRuleParent_uuid, isEvaluateOnlyByGates, isGateAnyRelation)
VALUES (unhex(@uuidGate),
        'ALLOW_METADATA_ACCESS',
        'Allow access to metadata endpoint',
        '$.path',
        11,
        '/query/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/metadata',
        false,
        true,
        NULL,
        true,
        false);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
SELECT privilege.uuid, unhex(@uuidGate)
from privilege,
     role_privilege,
     role
where privilege.uuid = role_privilege.privilege_id
  AND role_privilege.role_id = role.uuid
  AND role.name = 'FENCE_ROLE_OPEN_ACCESS';

INSERT INTO privilege (uuid, name, description, application_id, queryScope)
VALUES (unhex(REPLACE(UUID(), '-', '')), 'FENCE_PRIV_DICTIONARY', 'Allow access to queries for Dictionary Resource',
        (SELECT uuid FROM application WHERE name = 'PICSURE'), '[]');

INSERT INTO role_privilege (role_id, privilege_id)
VALUES ((select uuid from role where name = 'FENCE_ROLE_OPEN_ACCESS'),
        (select uuid from privilege where name = 'FENCE_PRIV_DICTIONARY'));

INSERT INTO access_rule
VALUES (unhex(REPLACE(UUID(), '-', '')), 'AR_ALLOW_DICTIONARY_ACCESS', 'allow access to dictionary resource',
        '$.query.resourceUUID', 9,
        '36363664-6231-6134-2d38-6538652d3131', 0, 0, NULL, 0, 0);

INSERT INTO access_rule
VALUES (unhex(REPLACE(UUID(), '-', '')), "AR_DICTIONARY_ONLY_SEARCH", "Dictionary Search", "$.['Target Service']", 6,
        "/search/36363664-6231-6134-2d38-6538652d3131", 0, 0, NULL, 0, 0);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
VALUES ((select uuid from privilege where name = 'FENCE_PRIV_DICTIONARY'),
        (select uuid
         from access_rule
         where name = 'AR_ALLOW_DICTIONARY_ACCESS'
           AND value = '36363664-6231-6134-2d38-6538652d3131'));

INSERT INTO accessRule_privilege
VALUES ((SELECT uuid FROM privilege WHERE name = 'FENCE_PRIV_DICTIONARY'),
        (SELECT uuid
         FROM access_rule
         WHERE name = 'AR_DICTIONARY_ONLY_SEARCH'
           AND value = '/search/36363664-6231-6134-2d38-6538652d3131'));

INSERT INTO access_rule
VALUES (unhex(REPLACE(UUID(), '-', '')), 'AR_ALLOW_DICTIONARY_ACCESS', 'allow access to dictionary resource',
        '$.query.resourceUUID', 9,
        '4c6e53d0-0860-4129-9bbd-568b18833f98', 0, 0, NULL, 0, 0);

INSERT INTO access_rule
VALUES (unhex(REPLACE(UUID(), '-', '')), "AR_DICTIONARY_ONLY_SEARCH", "Dictionary Search", "$.['Target Service']", 6,
        "/search/4c6e53d0-0860-4129-9bbd-568b18833f98", 0, 0, NULL, 0, 0);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
VALUES ((select uuid from privilege where name = 'FENCE_PRIV_DICTIONARY'),
        (select uuid
         from access_rule
         where name = 'AR_ALLOW_DICTIONARY_ACCESS'
           AND value = '4c6e53d0-0860-4129-9bbd-568b18833f98'));

INSERT INTO accessRule_privilege
VALUES ((SELECT uuid FROM privilege WHERE name = 'FENCE_PRIV_DICTIONARY'),
        (SELECT uuid
         FROM access_rule
         WHERE name = 'AR_DICTIONARY_ONLY_SEARCH'
           AND value = '/search/4c6e53d0-0860-4129-9bbd-568b18833f98'));