-- MySQL dump 10.13  Distrib 5.7.28, for Linux (x86_64)
--
-- Host: localhost    Database: picsure
-- ------------------------------------------------------
-- Server version	5.7.28
--
-- 10/28/2020 - nc - edited to remove unused data.  Privileges and roles will now be created on-demand.

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

--
-- Current Database: `picsure`
--

/*!40000 DROP DATABASE IF EXISTS `picsure`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `picsure` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_bin */;

USE `picsure`;

--
-- Table structure for table `query`
--

DROP TABLE IF EXISTS `query`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `query` (
  `uuid` binary(16) NOT NULL,
  `query` longblob,
  `readyTime` date DEFAULT NULL,
  `resourceResultId` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `startTime` date DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `resourceId` binary(16) DEFAULT NULL,
  `metadata` blob,
  PRIMARY KEY (`uuid`),
  KEY `FKhgiwd8kmi6pjw16txfhyqk2w0` (`resourceId`),
  CONSTRAINT `FKhgiwd8kmi6pjw16txfhyqk2w0` FOREIGN KEY (`resourceId`) REFERENCES `resource` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `query`
--

LOCK TABLES `query` WRITE;
/*!40000 ALTER TABLE `query` DISABLE KEYS */;
/*!40000 ALTER TABLE `query` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource`
--

DROP TABLE IF EXISTS `resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource` (
  `uuid` binary(16) NOT NULL,
  `targetURL` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `resourceRSPath` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `description` varchar(8192) COLLATE utf8_bin DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `token` varchar(8192) COLLATE utf8_bin DEFAULT NULL,
  `hidden` BOOL default NULL,
  `metadata` TEXT default NULL,
  PRIMARY KEY (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource`
--

LOCK TABLES `resource` WRITE;
/*!40000 ALTER TABLE `resource` DISABLE KEYS */;
INSERT INTO `resource` VALUES (0x02E23F52F3544E8B992CD37C8B9BA140,NULL,'http://auth-hpds.${target-stack}.datastage.hms.harvard.edu:8080/PIC-SURE/','Authorized Access HPDS resource','auth-hpds',NULL, NULL, NULL);
INSERT INTO `resource` VALUES (0x70c837be5ffc11ebae930242ac130002,NULL,'http://localhost:8080/pic-sure-aggregate-resource/pic-sure/aggregate-data-sharing','Open Access (aggregate) resource','open-hpds',NULL, NULL, NULL);
INSERT INTO `resource` VALUES (0x36363664623161342d386538652d3131,NULL,'http://dictionary.${target-stack}.datastage.hms.harvard.edu:8080/dictionary/pic-sure','Dictionary','dictionary',NULL, NULL, NULL);
/*!40000 ALTER TABLE `resource` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `uuid` binary(16) NOT NULL,
  `roles` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `userId` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `subject_UNIQUE` (`subject`),
  UNIQUE KEY `userId_UNIQUE` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Current Database: `auth`
--

/*!40000 DROP DATABASE IF EXISTS `auth`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `auth` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_bin */;

USE `auth`;

--
-- Table structure for table `accessRule_gate`
--

DROP TABLE IF EXISTS `accessRule_gate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accessRule_gate` (
  `accessRule_id` binary(16) NOT NULL,
  `gate_id` binary(16) NOT NULL,
  PRIMARY KEY (`accessRule_id`,`gate_id`),
  KEY `FK6re4kcq9tyl45jv9yg584doem` (`gate_id`),
  CONSTRAINT `FK6re4kcq9tyl45jv9yg584doem` FOREIGN KEY (`gate_id`) REFERENCES `access_rule` (`uuid`),
  CONSTRAINT `FKe6l5ee7f207958mm3anpsmqom` FOREIGN KEY (`accessRule_id`) REFERENCES `access_rule` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `accessRule_privilege`
--

DROP TABLE IF EXISTS `accessRule_privilege`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accessRule_privilege` (
  `privilege_id` binary(16) NOT NULL,
  `accessRule_id` binary(16) NOT NULL,
  PRIMARY KEY (`privilege_id`,`accessRule_id`),
  KEY `FK89rf30kbf9d246jty2dd7qk99` (`accessRule_id`),
  CONSTRAINT `FK7x47w81gpua380qd7lp9x94l1` FOREIGN KEY (`privilege_id`) REFERENCES `privilege` (`uuid`),
  CONSTRAINT `FK89rf30kbf9d246jty2dd7qk99` FOREIGN KEY (`accessRule_id`) REFERENCES `access_rule` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;



--
-- Table structure for table `access_rule`
--

DROP TABLE IF EXISTS `access_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_rule` (
  `uuid` binary(16) NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `description` varchar(2000) COLLATE utf8_bin DEFAULT NULL,
  `rule` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `value` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `checkMapKeyOnly` bit(1) NOT NULL,
  `checkMapNode` bit(1) NOT NULL,
  `subAccessRuleParent_uuid` binary(16) DEFAULT NULL,
  `isGateAnyRelation` bit(1) NOT NULL,
  `isEvaluateOnlyByGates` bit(1) NOT NULL,
  PRIMARY KEY (`uuid`),
  KEY `FK8rovvx363ui99ce21sksmg6uy` (`subAccessRuleParent_uuid`),
  CONSTRAINT `FK8rovvx363ui99ce21sksmg6uy` FOREIGN KEY (`subAccessRuleParent_uuid`) REFERENCES `access_rule` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;



--
-- Table structure for table `accessRule_subRule`
--
CREATE TABLE `accessRule_subRule` (
  `accessRule_id` binary(16) NOT NULL,
  `subRule_id` binary(16) NOT NULL,
  PRIMARY KEY (`accessRule_id`,`subRule_id`),
  KEY  (`subRule_id`),
  CONSTRAINT  FOREIGN KEY (`subRule_id`) REFERENCES `access_rule` (`uuid`),
  CONSTRAINT  FOREIGN KEY (`accessRule_id`) REFERENCES `access_rule` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


--
-- Table structure for table `application`
--

DROP TABLE IF EXISTS `application`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application` (
  `uuid` binary(16) NOT NULL,
  `description` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `enable` bit(1) NOT NULL DEFAULT b'1',
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `token` varchar(2000) COLLATE utf8_bin DEFAULT NULL,
  `url` varchar(500) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application`
--

LOCK TABLES `application` WRITE;
/*!40000 ALTER TABLE `application` DISABLE KEYS */;
INSERT INTO `application` VALUES (0x8B5722C962FD48D6B0BF4F67E53EFB2B,'PIC-SURE multiple data access API',0x01,'PICSURE','${picsure_token_introspection_token}','/picsureui');
/*!40000 ALTER TABLE `application` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `connection`
--

DROP TABLE IF EXISTS `connection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connection` (
  `uuid` binary(16) NOT NULL,
  `label` varchar(255) COLLATE utf8_bin NOT NULL,
  `id` varchar(255) COLLATE utf8_bin NOT NULL,
  `subprefix` varchar(255) COLLATE utf8_bin NOT NULL,
  `requiredFields` varchar(9000) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `connection`
--

LOCK TABLES `connection` WRITE;
/*!40000 ALTER TABLE `connection` DISABLE KEYS */;
INSERT INTO `connection` VALUES (0xD8C456813239437C951D706D5E56CAB8,'FENCE','fence','fence|','[{\"label\":\"email\",\"id\":\"email\"}]');
/*!40000 ALTER TABLE `connection` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `privilege`
--

DROP TABLE IF EXISTS `privilege`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `privilege` (
  `uuid` binary(16) NOT NULL,
  `description` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `application_id` binary(16) DEFAULT NULL,
  `queryTemplate` varchar(8192) COLLATE utf8_bin DEFAULT NULL,
  `queryScope` varchar(512) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `UK_h7iwbdg4ev8mgvmij76881tx8` (`name`),
  KEY `FK61h3jewffk70b5ni4tsi5rhoy` (`application_id`),
  CONSTRAINT `FK61h3jewffk70b5ni4tsi5rhoy` FOREIGN KEY (`application_id`) REFERENCES `application` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `uuid` binary(16) NOT NULL,
  `name` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `role_privilege`
--

DROP TABLE IF EXISTS `role_privilege`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role_privilege` (
  `role_id` binary(16) NOT NULL,
  `privilege_id` binary(16) NOT NULL,
  PRIMARY KEY (`role_id`,`privilege_id`),
  KEY `FKdkwbrwb5r8h74m1v7dqmhp99c` (`privilege_id`),
  CONSTRAINT `FKdkwbrwb5r8h74m1v7dqmhp99c` FOREIGN KEY (`privilege_id`) REFERENCES `privilege` (`uuid`),
  CONSTRAINT `FKsykrtrdngu5iexmbti7lu9xa` FOREIGN KEY (`role_id`) REFERENCES `role` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `termsOfService`
--

DROP TABLE IF EXISTS `termsOfService`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `termsOfService` (
  `uuid` binary(16) NOT NULL,
  `dateUpdated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `content` varchar(9000) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `uuid` binary(16) NOT NULL,
  `auth0_metadata` longtext COLLATE utf8_bin DEFAULT NULL,
  `general_metadata` longtext COLLATE utf8_bin DEFAULT NULL,
  `acceptedTOS` datetime DEFAULT NULL,
  `connectionId` binary(16) DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `matched` bit(1) NOT NULL DEFAULT b'0',
  `subject` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `is_active` bit(1) NOT NULL DEFAULT b'1',
  `long_term_token` varchar(4000) COLLATE utf8_bin DEFAULT NULL,
  `isGateAnyRelation` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `UK_r8xpakluitn685ua7pt8xjy9r` (`subject`),
  KEY `FKn8bku0vydfcnuwbqwgnbgg8ry` (`connectionId`),
  CONSTRAINT `FKn8bku0vydfcnuwbqwgnbgg8ry` FOREIGN KEY (`connectionId`) REFERENCES `connection` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `userMetadataMapping`
--

DROP TABLE IF EXISTS `userMetadataMapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userMetadataMapping` (
  `uuid` binary(16) NOT NULL,
  `auth0MetadataJsonPath` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `connectionId` binary(16) DEFAULT NULL,
  `generalMetadataJsonPath` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  KEY `FKayr8vrvvwpgsdhxdyryt6k590` (`connectionId`),
  CONSTRAINT `FKayr8vrvvwpgsdhxdyryt6k590` FOREIGN KEY (`connectionId`) REFERENCES `connection` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_role`
--

DROP TABLE IF EXISTS `user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_role` (
  `user_id` binary(16) NOT NULL,
  `role_id` binary(16) NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `FKa68196081fvovjhkek5m97n3y` (`role_id`),
  CONSTRAINT `FK859n2jvi8ivhui0rl0esws6o` FOREIGN KEY (`user_id`) REFERENCES `user` (`uuid`),
  CONSTRAINT `FKa68196081fvovjhkek5m97n3y` FOREIGN KEY (`role_id`) REFERENCES `role` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

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


  SET @uuidAR_INFO_COLUMN_LISTING_ALLOWED = REPLACE(UUID(),'-','');
  INSERT INTO access_rule VALUES (
    unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED),
    'AR_INFO_COLUMN_LISTING',
    'allow query to info_column_listing',
    '$.query.query.expectedResultType',
    4,
    'INFO_COLUMN_LISTING',
    0,
    1,
    NULL,
    0,
    0
  );


  SET @uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED = REPLACE(UUID(),'-','');
  INSERT INTO access_rule VALUES (
    unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED),
    'GATE_DONOT_ALLOW_INFO_COLUMN_LISTING',
    'reject info_column_listing query',
    '$.query.query.expectedResultType',
    3,
    'INFO_COLUMN_LISTING',
    0,
    1,
    NULL,
    0,
    0
  );

  SET @uuidAR_NO_QUERY_ACCESS = REPLACE(UUID(),'-','');
  INSERT INTO access_rule VALUES (
    unhex(@uuidAR_NO_QUERY_ACCESS),
    'AR_NO_QUERY_ACCESS',
    'Restrict to any query endpoints',
    '$.[\'Target Service\']',
    1,
    '/query ',
    0,
    0,
    NULL,
    0,
    0
  );

 SET @uuidGATE_QUERY = REPLACE(UUID(),'-','');
  INSERT INTO access_rule VALUES (
    unhex(@uuidGATE_QUERY),
    'GATE_QUERY',
    'triggers if user submits a query',
    '$.[\'Target Service\']',
    6,
    '/query ',
    0,
    0,
    NULL,
    0,
    0
  );

INSERT INTO accessRule_gate (gate_id, accessRule_id)
	VALUES (
		unhex(@uuidGATE_QUERY),
		unhex(@uuidAR_NO_QUERY_ACCESS)
	);


  SET @uuidAR_ONLY_INFO = REPLACE(UUID(),'-','');
  INSERT INTO access_rule VALUES (
    unhex(@uuidAR_ONLY_INFO),
    'AR_ONLY_INFO',
    'Can only do /info',
    '$.[\'Target Service\']',
    6,
    '/info',
    0,
    0,
    NULL,
    0,
    0
  );

  SET @uuidAR_ONLY_SEARCH = REPLACE(UUID(),'-','');
  INSERT INTO access_rule VALUES (
    unhex(@uuidAR_ONLY_SEARCH),
    'AR_ONLY_SEARCH',
    'Can only do /search',
    ' $.[\'Target Service\']',
    6,
    '/search',
    0,
    0,
    NULL,
    0,
    0
  );

SET @uuidAR_NO_SEARCH = REPLACE(UUID(),'-','');
  INSERT INTO access_rule VALUES (
    unhex(@uuidAR_NO_SEARCH),
    'AR_NO_SEARCH',
    'reject queries for /search',
    ' $.[\'Target Service\']',
    1,
    '/search',
    0,
    0,
    NULL,
    0,
    0
  );

SET @uuid_GATE_SEARCH = REPLACE(UUID(),'-','');
  INSERT INTO access_rule VALUES (
    unhex(@uuid_GATE_SEARCH),
    'GATE_SEARCH',
    'Triggers on search requests',
    ' $.[\'Target Service\']',
    6,
    '/search',
    0,
    0,
    NULL,
    0,
    0
  );

INSERT INTO accessRule_gate (gate_id, accessRule_id)
	VALUES (
		unhex(@uuid_GATE_SEARCH),
		unhex(@uuidAR_NO_SEARCH)
	);


--
-- Add a rule and privilege to allow all queries for open hpds resource.  This must match the ID of the resource
-- specified earlier in this file. (type 9 is ALL_EQUALS_IGNORE_CASE)
--

SET @uuidAR_OPEN_QUERIES = REPLACE(UUID(),'-','');
  INSERT INTO access_rule VALUES (
    unhex(@uuidAR_OPEN_QUERIES),
    'AR_ALLOW_OPEN_ACCESS',
    'allow access to open hpds resource',
    '$.query.resourceUUID',
    9,
    '70c837be-5ffc-11eb-ae93-0242ac130002',
    0,
    0,
    NULL,
    0,
    0
  );


SET @uuidPriv = REPLACE(UUID(),'-','');
INSERT INTO privilege (uuid, name, description, application_id, queryScope)
	VALUES ( unhex(@uuidPriv),
		'FENCE_PRIV_OPEN_ACCESS',
		'Allow access to queries for OPEN PICSURE',
		(SELECT uuid FROM application WHERE name = 'PICSURE'),
		'[]'
	);

INSERT INTO accessRule_privilege (privilege_id, accessRule_id)
	VALUES (
		unhex(@uuidPriv),
		unhex(@uuidAR_OPEN_QUERIES)
	);

 SET @uuidRole = REPLACE(UUID(),'-','');
  INSERT INTO role VALUES (
      unhex(@uuidRole),
     'FENCE_ROLE_OPEN_ACCESS',
     'This role will allow users to log in and query OPEN PICSURE'
  );

INSERT INTO role_privilege (role_id, privilege_id)
	VALUES (
		unhex(@uuidRole),
		unhex(@uuidPriv)
	);


INSERT INTO access_rule VALUES (
  unhex(REPLACE(UUID(),'-','')),
  "AR_OPEN_ONLY_SEARCH",
  "Open PIC-SURE Search",
  "$.['Target Service']",
  6,
  "/search/70c837be-5ffc-11eb-ae93-0242ac130002",
  0,
  0,
  NULL,
  0,
  0
);

INSERT INTO accessRule_privilege VALUES (
  (SELECT uuid FROM privilege WHERE name = 'FENCE_PRIV_OPEN_ACCESS'),
  (SELECT uuid FROM access_rule WHERE name = 'AR_OPEN_ONLY_SEARCH')
);


--
-- Add a rule and privilege to allow any and all requests to the dictionary resource.  
--

INSERT INTO access_rule VALUES (uuid(),'AR_ALLOW_DICTIONARY_ACCESS','allow access to dictionary resource','$.query.resourceUUID',9,'36363664-6231-6134-2d38-6538652d3131',0, 0, NULL,0,0);

INSERT INTO privilege (uuid, name, description, application_id, queryScope) VALUES ( uuid(), 'FENCE_PRIV_DICTIONARY', 'Allow access to queries for OPEN PICSURE', (SELECT uuid FROM application WHERE name = 'PICSURE'), '[]' );

INSERT INTO accessRule_privilege (privilege_id, accessRule_id) VALUES ((select uuid from privilege where name='FENCE_PRIV_DICTIONARY'), (select uuid from access_rule where name='AR_ALLOW_DICTIONARY_ACCESS'));

INSERT INTO role_privilege (role_id, privilege_id) VALUES ( (select uuid from role where name='FENCE_ROLE_OPEN_ACCESS'), (select uuid from privilege where name='FENCE_PRIV_DICTIONARY'));

INSERT INTO access_rule VALUES (  unhex(REPLACE(UUID(),'-','')), "AR_DICTIONARY_ONLY_SEARCH",  "Dictionary Search",  "$.['Target Service']",  6, "/search/36363664-6231-6134-2d38-6538652d3131", 0,  0,  NULL,  0, 0 );

INSERT INTO accessRule_privilege VALUES (
  (SELECT uuid FROM privilege WHERE name = 'FENCE_PRIV_DICTIONARY'), 
  (SELECT uuid FROM access_rule WHERE name = 'AR_DICTIONARY_ONLY_SEARCH')
);
