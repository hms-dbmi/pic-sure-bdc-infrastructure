-- MySQL dump 10.13  Distrib 5.7.28, for Linux (x86_64)
--
-- Host: localhost    Database: picsure
-- ------------------------------------------------------
-- Server version	5.7.28

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
  PRIMARY KEY (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource`
--

LOCK TABLES `resource` WRITE;
/*!40000 ALTER TABLE `resource` DISABLE KEYS */;
INSERT INTO `resource` VALUES (0x02E23F52F3544E8B992CD37C8B9BA140,NULL,'http://hpds.${target-stack}.datastage.hms.harvard.edu:8080/PIC-SURE/','Basic HPDS resource','hpds',NULL);
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
-- Dumping data for table `accessRule_gate`
--

LOCK TABLES `accessRule_gate` WRITE;
/*!40000 ALTER TABLE `accessRule_gate` DISABLE KEYS */;
/*!40000 ALTER TABLE `accessRule_gate` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `accessRule_privilege`
--

LOCK TABLES `accessRule_privilege` WRITE;
/*!40000 ALTER TABLE `accessRule_privilege` DISABLE KEYS */;
/*!40000 ALTER TABLE `accessRule_privilege` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `access_rule`
--

LOCK TABLES `access_rule` WRITE;
/*!40000 ALTER TABLE `access_rule` DISABLE KEYS */;
/*!40000 ALTER TABLE `access_rule` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `privilege`
--

LOCK TABLES `privilege` WRITE;
/*!40000 ALTER TABLE `privilege` DISABLE KEYS */;

INSERT INTO `privilege` VALUES (0x7044061AF65B425F86CE73A1BF7F4402,'PIC-SURE Auth super admin for managing roles/privileges/application/connections','SUPER_ADMIN',NULL,NULL,NULL),(0xAD08212E096F414CBA8D1BAE09415DAB,'PIC-SURE Auth admin for managing users.','ADMIN',NULL,NULL,NULL);

/*!40000 ALTER TABLE `privilege` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;

INSERT INTO `role` VALUES (0x002DC366B0D8420F998F885D0ED797FD,'PIC-SURE Top Admin','PIC-SURE Auth Micro App Top admin including Admin and super Admin');

/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `role_privilege`
--

LOCK TABLES `role_privilege` WRITE;
/*!40000 ALTER TABLE `role_privilege` DISABLE KEYS */;
INSERT INTO `role_privilege` VALUES (0x002DC366B0D8420F998F885D0ED797FD,0x7044061AF65B425F86CE73A1BF7F4402),(0x002DC366B0D8420F998F885D0ED797FD,0xAD08212E096F414CBA8D1BAE09415DAB);

/*!40000 ALTER TABLE `role_privilege` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `termsOfService`
--

LOCK TABLES `termsOfService` WRITE;
/*!40000 ALTER TABLE `termsOfService` DISABLE KEYS */;
/*!40000 ALTER TABLE `termsOfService` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

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
-- Dumping data for table `userMetadataMapping`
--

LOCK TABLES `userMetadataMapping` WRITE;
/*!40000 ALTER TABLE `userMetadataMapping` DISABLE KEYS */;
/*!40000 ALTER TABLE `userMetadataMapping` ENABLE KEYS */;
UNLOCK TABLES;

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

--
-- Dumping data for table `user_role`
--

LOCK TABLES `user_role` WRITE;
/*!40000 ALTER TABLE `user_role` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_role` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-01-09 15:33:01

--
-- This file will remove all roles/privileges/access_rules and re-create them
--

DELETE FROM accessRule_privilege;
DELETE FROM accessRule_gate;
DELETE FROM access_rule;
DELETE FROM role_privilege;
DELETE FROM privilege WHERE name LIKE 'PRIV_FENCE_%';
DELETE FROM user_role WHERE role_id IN (SELECT uuid FROM role WHERE name LIKE 'FENCE_%');
DELETE FROM role WHERE name LIKE 'FENCE_%';
  
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
    'allow query to info_column_listing',
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

  SET @uuidAR_ONLY_INFO = REPLACE(UUID(),'-','');
  INSERT INTO access_rule VALUES (
    unhex(@uuidAR_ONLY_INFO),
    'AR_ONLY_INFO',
    'Can only do /query, /info and /search',
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
    'Can only do /query, /info and /search',
    ' $.[\'Target Service\']',
    6,
    '/search',
    0,
    0,
    NULL,
    0,
    0
  );

  SET @uuidAR_ONLY_QUERY = REPLACE(UUID(),'-','');
  INSERT INTO access_rule VALUES (
    unhex(@uuidAR_ONLY_QUERY),
    'AR_ONLY_QUERY',
    'Can only do /query, /info and /search',
    ' $.[\'Target Service\']',
    6,
    '/query',
    0,
    0,
    NULL,
    0,
    0
  );



  SET @uuidRole = REPLACE(UUID(),'-','');
  INSERT INTO role VALUES ( 
      unhex(@uuidRole), 
     'FENCE_topmed', 
     'Special role to include all privileges' 
  );
    
 
   SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000007_c0',
      'For study Framingham Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Framingham Cohort', 
      'PRIV_FENCE_phs000007_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000007.c0"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Framingham Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000007_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000007.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000007_c1',
      'For study Framingham Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Framingham Cohort', 
      'PRIV_FENCE_phs000007_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000007.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Framingham Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000007_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000007.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000007_c2',
      'For study Framingham Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Framingham Cohort', 
      'PRIV_FENCE_phs000007_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000007.c2"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Framingham Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000007_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000007.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));


 SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000179_c0',
      'For study Genetic Epidemiology of COPD (COPDGene)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genetic Epidemiology of COPD (COPDGene)', 
      'PRIV_FENCE_phs000179_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000179.c0"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genetic Epidemiology of COPD (COPDGene)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000179_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000179.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000179_c1',
      'For study Genetic Epidemiology of COPD (COPDGene)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genetic Epidemiology of COPD (COPDGene)', 
      'PRIV_FENCE_phs000179_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000179.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genetic Epidemiology of COPD (COPDGene)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000179_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000179.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000179_c2',
      'For study Genetic Epidemiology of COPD (COPDGene)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genetic Epidemiology of COPD (COPDGene)', 
      'PRIV_FENCE_phs000179_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000179.c2"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genetic Epidemiology of COPD (COPDGene)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000179_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000179.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));



   SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000209_c0',
      'For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort', 
      'PRIV_FENCE_phs000209_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000209.c0"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Multi-Ethnic Study of Atherosclerosis (MESA) Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000209_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000209.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000209_c1',
      'For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort', 
      'PRIV_FENCE_phs000209_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000209.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Multi-Ethnic Study of Atherosclerosis (MESA) Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000209_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000209.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000209_c2',
      'For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort', 
      'PRIV_FENCE_phs000209_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000209.c2"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Multi-Ethnic Study of Atherosclerosis (MESA) Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000209_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000209.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    


  SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000280_c0',
      'For study Atherosclerosis Risk in Communities (ARIC) Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Atherosclerosis Risk in Communities (ARIC) Cohort', 
      'PRIV_FENCE_phs000280_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000280.c0"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Atherosclerosis Risk in Communities (ARIC) Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000280_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000280.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000280_c1',
      'For study Atherosclerosis Risk in Communities (ARIC) Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Atherosclerosis Risk in Communities (ARIC) Cohort', 
      'PRIV_FENCE_phs000280_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000280.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Atherosclerosis Risk in Communities (ARIC) Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000280_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000280.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000280_c2',
      'For study Atherosclerosis Risk in Communities (ARIC) Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Atherosclerosis Risk in Communities (ARIC) Cohort', 
      'PRIV_FENCE_phs000280_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000280.c2"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Atherosclerosis Risk in Communities (ARIC) Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000280_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000280.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        

 SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000284_c0',
      'For study NHLBI Cleveland Family Study (CFS) Candidate Gene Association Resource (CARe)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI Cleveland Family Study (CFS) Candidate Gene Association Resource (CARe)', 
      'PRIV_FENCE_phs000284_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000284.c0"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI Cleveland Family Study (CFS) Candidate Gene Association Resource (CARe)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000284_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000284.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000284_c1',
      'For study NHLBI Cleveland Family Study (CFS) Candidate Gene Association Resource (CARe)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI Cleveland Family Study (CFS) Candidate Gene Association Resource (CARe)', 
      'PRIV_FENCE_phs000284_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000284.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI Cleveland Family Study (CFS) Candidate Gene Association Resource (CARe)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000284_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000284.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000286_c0',
      'For study The Jackson Heart Study (JHS)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study The Jackson Heart Study (JHS)', 
      'PRIV_FENCE_phs000286_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000286.c0"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\The Jackson Heart Study (JHS)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000286_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000286.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000286_c1',
      'For study The Jackson Heart Study (JHS)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study The Jackson Heart Study (JHS)', 
      'PRIV_FENCE_phs000286_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000286.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\The Jackson Heart Study (JHS)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000286_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000286.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000286_c2',
      'For study The Jackson Heart Study (JHS)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study The Jackson Heart Study (JHS)', 
      'PRIV_FENCE_phs000286_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000286.c2"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\The Jackson Heart Study (JHS)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000286_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000286.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000286_c3',
      'For study The Jackson Heart Study (JHS)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study The Jackson Heart Study (JHS)', 
      'PRIV_FENCE_phs000286_c3', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000286.c3"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\The Jackson Heart Study (JHS)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000286_c3', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000286.c3", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000286_c4',
      'For study The Jackson Heart Study (JHS)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study The Jackson Heart Study (JHS)', 
      'PRIV_FENCE_phs000286_c4', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000286.c4"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\The Jackson Heart Study (JHS)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000286_c4', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000286.c4", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    


SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000287_c0',
      'For study Cardiovascular Health Study (CHS) Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Cardiovascular Health Study (CHS) Cohort', 
      'PRIV_FENCE_phs000287_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000287.c0"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Cardiovascular Health Study (CHS) Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000287_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000287.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000287_c1',
      'For study Cardiovascular Health Study (CHS) Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Cardiovascular Health Study (CHS) Cohort', 
      'PRIV_FENCE_phs000287_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000287.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Cardiovascular Health Study (CHS) Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000287_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000287.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000287_c2',
      'For study Cardiovascular Health Study (CHS) Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Cardiovascular Health Study (CHS) Cohort', 
      'PRIV_FENCE_phs000287_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000287.c2"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Cardiovascular Health Study (CHS) Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000287_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000287.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000287_c3',
      'For study Cardiovascular Health Study (CHS) Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Cardiovascular Health Study (CHS) Cohort', 
      'PRIV_FENCE_phs000287_c3', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000287.c3"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Cardiovascular Health Study (CHS) Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000287_c3', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000287.c3", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000287_c4',
      'For study Cardiovascular Health Study (CHS) Cohort'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Cardiovascular Health Study (CHS) Cohort', 
      'PRIV_FENCE_phs000287_c4', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000287.c4"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Cardiovascular Health Study (CHS) Cohort\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000287_c4', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000287.c4", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));




    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001402_c0',
      'For study NHGRI Genome-Wide Association Study of Venous Thromboembolism (GWAS of VTE)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHGRI Genome-Wide Association Study of Venous Thromboembolism (GWAS of VTE)', 
      'PRIV_FENCE_phs001402_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001402.c0"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHGRI Genome-Wide Association Study of Venous Thromboembolism (GWAS of VTE)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001402_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001402.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001402_c1',
      'For study NHGRI Genome-Wide Association Study of Venous Thromboembolism (GWAS of VTE)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHGRI Genome-Wide Association Study of Venous Thromboembolism (GWAS of VTE)', 
      'PRIV_FENCE_phs001402_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001402.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHGRI Genome-Wide Association Study of Venous Thromboembolism (GWAS of VTE)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001402_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001402.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    


    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001217_c0',
      'For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)', 
      'PRIV_FENCE_phs001217_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001217.c0"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genetic Epidemiology Network of Salt Sensitivity (GenSalt)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001217_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001217.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001217_c1',
      'For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)', 
      'PRIV_FENCE_phs001217_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001217.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genetic Epidemiology Network of Salt Sensitivity (GenSalt)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001217_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001217.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    


   SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001189_c1',
      'For study CCF AFIB GWAS study'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study CCF AFIB GWAS study', 
      'PRIV_FENCE_phs001189_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001189.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\CCF AFIB GWAS study\\\\", "\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001189_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001189.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    


   SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000914_c0',
      'For study Genome-wide Association Study of Adiposity in Samoans'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genome-wide Association Study of Adiposity in Samoans', 
      'PRIV_FENCE_phs000914_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000914.c0"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genome-wide Association Study of Adiposity in Samoans\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000914_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000914.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000914_c1',
      'For study Genome-wide Association Study of Adiposity in Samoans'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genome-wide Association Study of Adiposity in Samoans', 
      'PRIV_FENCE_phs000914_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000914.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genome-wide Association Study of Adiposity in Samoans\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000914_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000914.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000921_c2',
      'For study NHLBI TOPMed: Study of African Americans, Asthma, Genes and Environment (SAGE) Study'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: Study of African Americans, Asthma, Genes and Environment (SAGE) Study', 
      'PRIV_FENCE_phs000921_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000921.c2"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Study of African Americans, Asthma, Genes and Environment (SAGE) Study\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_","Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000921_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000921.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    


    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000946_c1',
      'For study NHLBI TOPMed: Boston Early-Onset COPD Study in the TOPMed Program'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: Boston Early-Onset COPD Study in the TOPMed Program', 
      'PRIV_FENCE_phs000946_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000946.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Boston Early-Onset COPD Study in the TOPMed Program\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000946_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000946.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

   SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000956_c0',
      'For study NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish', 
      'PRIV_FENCE_phs000956_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000956.c0"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000956_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000956.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000956_c2',
      'For study NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish', 
      'PRIV_FENCE_phs000956_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000956.c2"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000956_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000956.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000988_c0',
      'For study NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica', 
      'PRIV_FENCE_phs000988_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000988.c0"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000988_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000988.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000988_c1',
      'For study NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica', 
      'PRIV_FENCE_phs000988_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000988.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000988_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000988.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

   SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000997_c1',
      'For study NHLBI TOPMed: The Vanderbilt AF Ablation Registry'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: The Vanderbilt AF Ablation Registry', 
      'PRIV_FENCE_phs000997_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000997.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Vanderbilt AF Ablation Registry\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000997_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000997.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    


    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001001_c1',
      'For study MGH Atrial Fibrillation Study'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study MGH Atrial Fibrillation Study', 
      'PRIV_FENCE_phs001001_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001001.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\MGH Atrial Fibrillation Study\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001001_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001001.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001001_c2',
      'For study MGH Atrial Fibrillation Study'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study MGH Atrial Fibrillation Study', 
      'PRIV_FENCE_phs001001_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001001.c2"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\MGH Atrial Fibrillation Study\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001001_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001001.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

   SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001013_c1',
      'For study Heart and Vascular Health Study (HVH)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Heart and Vascular Health Study (HVH)', 
      'PRIV_FENCE_phs001013_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001013.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Heart and Vascular Health Study (HVH)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001013_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001013.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001013_c2',
      'For study Heart and Vascular Health Study (HVH)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Heart and Vascular Health Study (HVH)', 
      'PRIV_FENCE_phs001013_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001013.c2"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Heart and Vascular Health Study (HVH)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001013_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001013.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001024_c1',
      'For study NHLBI TOPMed: Partners HealthCare Biobank'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: Partners HealthCare Biobank', 
      'PRIV_FENCE_phs001024_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001024.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Partners HealthCare Biobank\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001024_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001024.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

  SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001032_c1',
      'For study NHLBI TOPMed: The Vanderbilt Atrial Fibrillation Registry'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: The Vanderbilt Atrial Fibrillation Registry', 
      'PRIV_FENCE_phs001032_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001032.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Vanderbilt Atrial Fibrillation Registry\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001032_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001032.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
    

    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001218_c0',
      'For study GeneSTAR NextGen Functional Genomics of Platelet Aggregation'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study GeneSTAR NextGen Functional Genomics of Platelet Aggregation', 
      'PRIV_FENCE_phs001218_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001218.c0"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\GeneSTAR NextGen Functional Genomics of Platelet Aggregation\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001218_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001218.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001218_c2',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs001218_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001218.c2"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001218_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001218.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

   SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001143_c0',
      'For study NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados', 
      'PRIV_FENCE_phs001143_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001143.c0"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001143_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001143.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001143_c1',
      'For study NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados', 
      'PRIV_FENCE_phs001143_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001143.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001143_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001143.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001207_c0',
      'For study NHLBI TOPMed: African American Sarcoidosis Genetics Resource'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: African American Sarcoidosis Genetics Resource', 
      'PRIV_FENCE_phs001207_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001207.c0"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: African American Sarcoidosis Genetics Resource\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001207_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001207.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001207_c1',
      'For study NHLBI TOPMed: African American Sarcoidosis Genetics Resource'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: African American Sarcoidosis Genetics Resource', 
      'PRIV_FENCE_phs001207_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001207.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: African American Sarcoidosis Genetics Resource\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001207_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001207.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001215_c0',
      'For study NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)', 
      'PRIV_FENCE_phs001215_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001215.c0"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001215_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001215.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001215_c1',
      'For study NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)', 
      'PRIV_FENCE_phs001215_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001215.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001215_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001215.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    


  SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001238_c0',
      'For study Genetic Epidemiology Network of Arteriopathy (GENOA)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genetic Epidemiology Network of Arteriopathy (GENOA)', 
      'PRIV_FENCE_phs001238_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001238.c0"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genetic Epidemiology Network of Arteriopathy (GENOA)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001238_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001238.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001238_c1',
      'For study Genetic Epidemiology Network of Arteriopathy (GENOA)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genetic Epidemiology Network of Arteriopathy (GENOA)', 
      'PRIV_FENCE_phs001238_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001238.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genetic Epidemiology Network of Arteriopathy (GENOA)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001238_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001238.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

  SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001293_c0',
      'For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy', 
      'PRIV_FENCE_phs001293_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001293.c0"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001293_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001293.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001293_c1',
      'For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy', 
      'PRIV_FENCE_phs001293_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001293.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001293_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001293.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001293_c2',
      'For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy', 
      'PRIV_FENCE_phs001293_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001293.c2"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001293_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001293.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    


    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001387_c0',
      'For study NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)', 
      'PRIV_FENCE_phs001387_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001387.c0"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001387_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001387.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001387_c3',
      'For study NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)', 
      'PRIV_FENCE_phs001387_c3', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001387.c3"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001387_c3', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001387.c3", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001412_c0',
      'For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)', 
      'PRIV_FENCE_phs001412_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001412.c0"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001412_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001412.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001412_c1',
      'For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)', 
      'PRIV_FENCE_phs001412_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001412.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001412_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001412.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001412_c2',
      'For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)', 
      'PRIV_FENCE_phs001412_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001412.c2"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_", "Variant_consequence_calculated","Variant_class","Gene_with_variant","Variant_severity","Variant_frequency_in_gnomAD","Variant_frequency_as_text"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001412_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001412.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    
          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));




   SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001180_c0',
      'For study Genes-Environments and Admixture in Latino Asthmatics (GALA II) Study'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genes-Environments and Admixture in Latino Asthmatics (GALA II) Study', 
      'PRIV_FENCE_phs001180_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001180.c0"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genes-Environments and Admixture in Latino Asthmatics (GALA II) Study\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001180_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001180.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001180_c2',
      'For study Genes-Environments and Admixture in Latino Asthmatics (GALA II) Study'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genes-Environments and Admixture in Latino Asthmatics (GALA II) Study', 
      'PRIV_FENCE_phs001180_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001180.c2"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genes-Environments and Admixture in Latino Asthmatics (GALA II) Study\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001180_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001180.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs001040_c1',
      'For study Novel Risk Factors for the Development of Atrial Fibrillation in Women'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Novel Risk Factors for the Development of Atrial Fibrillation in Women', 
      'PRIV_FENCE_phs001040_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001040.c1"]},"numericFilters":{},"fields":["\\\\_Topmed Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Novel Risk Factors for the Development of Atrial Fibrillation in Women\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001040_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001040.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000200_c0',
      'For study Women\'s Health Initiative'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Women\'s Health Initiative', 
      'PRIV_FENCE_phs000200_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000200.c0"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Women\'s Health Initiative\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000200_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000200.c0", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    

    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000200_c1',
      'For study Women\'s Health Initiative'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Women\'s Health Initiative', 
      'PRIV_FENCE_phs000200_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000200.c1"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Women\'s Health Initiative\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000200_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000200.c1", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));
    
        
    SET @uuidRole = REPLACE(UUID(),'-','');
    INSERT INTO role VALUES (
      unhex(@uuidRole),
      'FENCE_phs000200_c2',
      'For study Women\'s Health Initiative'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Women\'s Health Initiative', 
      'PRIV_FENCE_phs000200_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000200.c2"]},"numericFilters":{},"fields":["\\\\_Parent Study Accession with Subject ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Women\'s Health Initiative\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000200_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000200.c2", 
          0, 
          1, 
          NULL, 
          0, 
          0
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidACCESSRULE)
        );
  
        --  INSERT INTO accessRule_gate VALUES (
        --    unhex(@uuidACCESSRULE),
        --    (SELECT uuid FROM access_rule WHERE name = 'GATE_EXPECTED_RESULT_TYPE')
        --  );
  
        INSERT INTO accessRule_gate VALUES (
          unhex(@uuidACCESSRULE),
          unhex(@uuidAR_INFO_COLUMN_LISTING_NOT_ALLOWED)
        );
  
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          unhex(@uuidAR_INFO_COLUMN_LISTING_ALLOWED)
        );

        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_QUERY')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_INFO')
        );
    
        INSERT INTO accessRule_privilege VALUES (
          unhex(@uuidPriv),
          (SELECT uuid FROM access_rule WHERE name = 'AR_ONLY_SEARCH')
        );
    

          
    INSERT INTO role_privilege VALUES ( unhex(@uuidRole), unhex(@uuidPriv) );
    INSERT INTO role_privilege VALUES ( (SELECT uuid FROM role WHERE name = 'FENCE_topmed'), unhex(@uuidPriv));







    
delete from accessRule_privilege where accessRule_id = (select uuid from access_rule where name = 'AR_ONLY_QUERY');
 
