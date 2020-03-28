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
INSERT INTO `privilege` VALUES (0x7044061AF65B425F86CE73A1BF7F4402,'PIC-SURE Auth super admin for managing roles/privileges/application/connections','SUPER_ADMIN',NULL,NULL,NULL),(0xAD08212E096F414CBA8D1BAE09415DAB,'PIC-SURE Auth admin for managing users.','ADMIN',NULL,NULL,NULL),(0xED81AAB8179A11EABA2F0242C0A81002,'For study Atherosclerosis Risk in Communities (ARIC) Cohort','PRIV_FENCE_phs000280_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000280.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Atherosclerosis_Risk_in_Communities_ARIC_Cohort\",\"DCC_Harmonized_data_set\"]'),(0xED830599179A11EABA2F0242C0A81002,'For study Atherosclerosis Risk in Communities (ARIC) Cohort','PRIV_FENCE_phs000280_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000280.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Atherosclerosis_Risk_in_Communities_ARIC_Cohort\",\"DCC_Harmonized_data_set\"]'),(0xED8C37A9179A11EABA2F0242C0A81002,'For study Cardiovascular Health Study (CHS) Cohort','PRIV_FENCE_phs000287_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000287.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Cardiovascular_Health_Study_CHS_Cohort\",\"DCC_Harmonized_data_set\"]'),(0xED8D687C179A11EABA2F0242C0A81002,'For study Cardiovascular Health Study (CHS) Cohort','PRIV_FENCE_phs000287_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000287.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Cardiovascular_Health_Study_CHS_Cohort\",\"DCC_Harmonized_data_set\"]'),(0xED8E7903179A11EABA2F0242C0A81002,'For study Cardiovascular Health Study (CHS) Cohort','PRIV_FENCE_phs000287_c3',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000287.c3\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Cardiovascular_Health_Study_CHS_Cohort\",\"DCC_Harmonized_data_set\"]'),(0xED8F7F1A179A11EABA2F0242C0A81002,'For study Cardiovascular Health Study (CHS) Cohort','PRIV_FENCE_phs000287_c4',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000287.c4\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Cardiovascular_Health_Study_CHS_Cohort\",\"DCC_Harmonized_data_set\"]'),(0xED99ACEF179A11EABA2F0242C0A81002,'For study Framingham Cohort','PRIV_FENCE_phs000007_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000007.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Framingham_Cohort\",\"DCC_Harmonized_data_set\"]'),(0xED9AB7F1179A11EABA2F0242C0A81002,'For study Framingham Cohort','PRIV_FENCE_phs000007_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000007.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Framingham_Cohort\",\"DCC_Harmonized_data_set\"]'),(0xEDA8DB41179A11EABA2F0242C0A81002,'For study GeneSTAR NextGen Functional Genomics of Platelet Aggregation','PRIV_FENCE_phs001074_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001074.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"GeneSTAR_NextGen_Functional_Genomics_of_Platelet_Aggregation\",\"DCC_Harmonized_data_set\"]'),(0xEDB20308179A11EABA2F0242C0A81002,'For study Genes-Environments and Admixture in Latino Asthmatics (GALA II) Study','PRIV_FENCE_phs001180_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001180.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genes_Environments_and_Admixture_in_Latino_Asthmatics_GALA_II_Study\",\"DCC_Harmonized_data_set\"]'),(0xEDB5D5DC179A11EABA2F0242C0A81002,'For study Genetic Epidemiology Network of Arteriopathy (GENOA)','PRIV_FENCE_phs001238_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001238.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genetic_Epidemiology_Network_of_Arteriopathy_GENOA_\",\"DCC_Harmonized_data_set\"]'),(0xEDBED577179A11EABA2F0242C0A81002,'For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)','PRIV_FENCE_phs000784_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000784.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genetic_Epidemiology_Network_of_Salt_Sensitivity_GenSalt_\",\"DCC_Harmonized_data_set\"]'),(0xEDC7DD70179A11EABA2F0242C0A81002,'For study Genetic Epidemiology of COPD (COPDGene)','PRIV_FENCE_phs000179_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000179.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genetic_Epidemiology_of_COPD_COPDGene_\",\"DCC_Harmonized_data_set\"]'),(0xEDC8F07E179A11EABA2F0242C0A81002,'For study Genetic Epidemiology of COPD (COPDGene)','PRIV_FENCE_phs000179_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000179.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genetic_Epidemiology_of_COPD_COPDGene_\",\"DCC_Harmonized_data_set\"]'),(0xEDD113CB179A11EABA2F0242C0A81002,'For study Genetics of Lipid Lowering Drugs and Diet Network (GOLDN) Lipidomics Study','PRIV_FENCE_phs000741_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000741.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genetics_of_Lipid_Lowering_Drugs_and_Diet_Network_GOLDN_Lipidomics_Study\",\"DCC_Harmonized_data_set\"]'),(0xEDDEB790179A11EABA2F0242C0A81002,'For study Genome-wide Association Study of Adiposity in Samoans','PRIV_FENCE_phs000914_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000914.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genome_wide_Association_Study_of_Adiposity_in_Samoans\",\"DCC_Harmonized_data_set\"]'),(0xEDE327B5179A11EABA2F0242C0A81002,'For study Heart and Vascular Health Study (HVH)','PRIV_FENCE_phs001013_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001013.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Heart_and_Vascular_Health_Study_HVH_\",\"DCC_Harmonized_data_set\"]'),(0xEDE473BD179A11EABA2F0242C0A81002,'For study Heart and Vascular Health Study (HVH)','PRIV_FENCE_phs001013_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001013.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Heart_and_Vascular_Health_Study_HVH_\",\"DCC_Harmonized_data_set\"]'),(0xEDECB40A179A11EABA2F0242C0A81002,'For study MGH Atrial Fibrillation Study','PRIV_FENCE_phs001001_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001001.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"MGH_Atrial_Fibrillation_Study\",\"DCC_Harmonized_data_set\"]'),(0xEDEDD88F179A11EABA2F0242C0A81002,'For study MGH Atrial Fibrillation Study','PRIV_FENCE_phs001001_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001001.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"MGH_Atrial_Fibrillation_Study\",\"DCC_Harmonized_data_set\"]'),(0xEDF69116179A11EABA2F0242C0A81002,'For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort','PRIV_FENCE_phs000209_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000209.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Multi_Ethnic_Study_of_Atherosclerosis_MESA_Cohort\",\"DCC_Harmonized_data_set\"]'),(0xEDF7C811179A11EABA2F0242C0A81002,'For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort','PRIV_FENCE_phs000209_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000209.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Multi_Ethnic_Study_of_Atherosclerosis_MESA_Cohort\",\"DCC_Harmonized_data_set\"]'),(0xEE05C175179A11EABA2F0242C0A81002,'For study NHGRI Genome-Wide Association Study of Venous Thromboembolism (GWAS of VTE)','PRIV_FENCE_phs000289_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000289.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHGRI_Genome_Wide_Association_Study_of_Venous_Thromboembolism_GWAS_of_VTE_\",\"DCC_Harmonized_data_set\"]'),(0xEE0A61A8179A11EABA2F0242C0A81002,'For study NHLBI Cleveland Family Study (CFS) Candidate Gene Association Resource (CARe)','PRIV_FENCE_phs000284_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000284.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_Cleveland_Family_Study_CFS_Candidate_Gene_Association_Resource_CARe_\",\"DCC_Harmonized_data_set\"]'),(0xEE13752E179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: African American Sarcoidosis Genetics Resource','PRIV_FENCE_phs001207_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001207.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_African_American_Sarcoidosis_Genetics_Resource\",\"DCC_Harmonized_data_set\"]'),(0xEE188DDE179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: Boston Early-Onset COPD Study in the TOPMed Program','PRIV_FENCE_phs000946_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000946.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Boston_Early_Onset_COPD_Study_in_the_TOPMed_Program\",\"DCC_Harmonized_data_set\"]'),(0xEE1D1E5C179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)','PRIV_FENCE_phs001412_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001412.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Diabetes_Heart_Study_DHS_African_American_Coronary_Artery_Calcification_AA_CAC_\",\"DCC_Harmonized_data_set\"]'),(0xEE1E3757179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)','PRIV_FENCE_phs001412_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001412.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Diabetes_Heart_Study_DHS_African_American_Coronary_Artery_Calcification_AA_CAC_\",\"DCC_Harmonized_data_set\"]'),(0xEE22DD87179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish','PRIV_FENCE_phs000956_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000956.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Genetics_of_Cardiometabolic_Health_in_the_Amish\",\"DCC_Harmonized_data_set\"]'),(0xEE2660F5179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy','PRIV_FENCE_phs001293_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001293.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_HyperGEN__Genetics_of_Left_Ventricular_LV_Hypertrophy\",\"DCC_Harmonized_data_set\"]'),(0xEE277A5C179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy','PRIV_FENCE_phs001293_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001293.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_HyperGEN__Genetics_of_Left_Ventricular_LV_Hypertrophy\",\"DCC_Harmonized_data_set\"]'),(0xEE2ADBEE179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: Novel Risk Factors for the Development of Atrial Fibrillation in Women','PRIV_FENCE_phs001040_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001040.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Novel_Risk_Factors_for_the_Development_of_Atrial_Fibrillation_in_Women\",\"DCC_Harmonized_data_set\"]'),(0xEE2FAFCE179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: Partners HealthCare Biobank','PRIV_FENCE_phs001024_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001024.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Partners_HealthCare_Biobank\",\"DCC_Harmonized_data_set\"]'),(0xEE36F02D179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)','PRIV_FENCE_phs001387_c3',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001387.c3\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Rare_Variants_for_Hypertension_in_Taiwan_Chinese_THRV_\",\"DCC_Harmonized_data_set\"]'),(0xEE3976FD179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)','PRIV_FENCE_phs001215_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001215.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_San_Antonio_Family_Heart_Study_SAFHS_\",\"DCC_Harmonized_data_set\"]'),(0xEE3F4223179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: Study of African Americans, Asthma, Genes and Environment (SAGE) Study','PRIV_FENCE_phs000921_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000921.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Study_of_African_Americans,_Asthma,_Genes_and_Environment_SAGE_Study\",\"DCC_Harmonized_data_set\"]'),(0xEE42ADEC179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica','PRIV_FENCE_phs000988_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000988.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_The_Genetic_Epidemiology_of_Asthma_in_Costa_Rica\",\"DCC_Harmonized_data_set\"]'),(0xEE473FD1179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados','PRIV_FENCE_phs001143_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001143.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_The_Genetics_and_Epidemiology_of_Asthma_in_Barbados\",\"DCC_Harmonized_data_set\"]'),(0xEE4C0411179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: The Vanderbilt AF Ablation Registry','PRIV_FENCE_phs000997_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000997.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_The_Vanderbilt_AF_Ablation_Registry\",\"DCC_Harmonized_data_set\"]'),(0xEE509643179A11EABA2F0242C0A81002,'For study NHLBI TOPMed: The Vanderbilt Atrial Fibrillation Registry','PRIV_FENCE_phs001032_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001032.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_The_Vanderbilt_Atrial_Fibrillation_Registry\",\"DCC_Harmonized_data_set\"]'),(0xEE551CBA179A11EABA2F0242C0A81002,'For study The Jackson Heart Study (JHS)','PRIV_FENCE_phs000286_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000286.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"The_Jackson_Heart_Study_JHS_\",\"DCC_Harmonized_data_set\"]'),(0xEE563C06179A11EABA2F0242C0A81002,'For study The Jackson Heart Study (JHS)','PRIV_FENCE_phs000286_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000286.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"The_Jackson_Heart_Study_JHS_\",\"DCC_Harmonized_data_set\"]'),(0xEE575782179A11EABA2F0242C0A81002,'For study The Jackson Heart Study (JHS)','PRIV_FENCE_phs000286_c3',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000286.c3\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"The_Jackson_Heart_Study_JHS_\",\"DCC_Harmonized_data_set\"]'),(0xEE586B72179A11EABA2F0242C0A81002,'For study The Jackson Heart Study (JHS)','PRIV_FENCE_phs000286_c4',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000286.c4\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"The_Jackson_Heart_Study_JHS_\",\"DCC_Harmonized_data_set\"]'),(0xEE62FE9D179A11EABA2F0242C0A81002,'For study Women`s Health Initiative','PRIV_FENCE_phs000200_c1',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000200.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Women_s_Health_Initiative\",\"DCC_Harmonized_data_set\"]'),(0xEE640CE8179A11EABA2F0242C0A81002,'For study Women`s Health Initiative','PRIV_FENCE_phs000200_c2',0x8B5722C962FD48D6B0BF4F67E53EFB2B,'{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000200.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Women_s_Health_Initiative\",\"DCC_Harmonized_data_set\"]');
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
INSERT INTO `role` VALUES (0x002DC366B0D8420F998F885D0ED797FD,'PIC-SURE Top Admin','PIC-SURE Auth Micro App Top admin including Admin and super Admin'),(0x04AAAD4320F847F68FCAE27428996C20,'FENCE_phs001368_c2','FENCE role FENCE_phs001368_c2'),(0x082ECA1321144089B524F372C5616BC1,'FENCE_phs001434_c999','FENCE role FENCE_phs001434_c999'),(0x09354B07C6A247CC8D90B85644D3E526,'FENCE_phs000951_c2','FENCE role FENCE_phs000951_c2'),(0x167BF7DC7EC24502B0B1957C5D4FAA42,'FENCE_phs001237_c1','FENCE role FENCE_phs001237_c1'),(0x1C298F8E196842F1A983B4EE7432861F,'FENCE_phs001446_c999','FENCE role FENCE_phs001446_c999'),(0x318E5DDD9980437E99BBEDE8D1C18D50,'FENCE_phs000974_c1','FENCE role FENCE_phs000974_c1'),(0x31DCF75BED384463B8E9D46EE61EACA9,'FENCE_phs001189_c1','FENCE role FENCE_phs001189_c1'),(0x32A1992174BD4AE5AAC7D12191423708,'FENCE_phs001466_c3','FENCE role FENCE_phs001466_c3'),(0x474329AB20014E96B57C94B7AE22B835,'FENCE_phs000951_c1','FENCE role FENCE_phs000951_c1'),(0x4C00728449BA49B7A987A0EC78C5C0AF,'FENCE_phs001211_c1','FENCE role FENCE_phs001211_c1'),(0x54467DFA6B724F649C5CDF20681A68AE,'FENCE_phs000993_c1','FENCE role FENCE_phs000993_c1'),(0x59ABE7BF3CA94CEC815D1C8DEB008EA2,'FENCE_phs000954_c1','FENCE role FENCE_phs000954_c1'),(0x5AA9EE2FB2394F1186ACB89AA8FFB1E7,'FENCE_phs001211_c2','FENCE role FENCE_phs001211_c2'),(0x5C5E5A026B88470891681093B480E24B,'FENCE_phs000285_c1','FENCE role FENCE_phs000285_c1'),(0x5F08AD0F91254B66B4AD91488D5C7BF0,'FENCE_phs001237_c2','FENCE role FENCE_phs001237_c2'),(0x701B7E1B292A44A0BB6724102CA94C39,'FENCE_phs001416_c1','FENCE role FENCE_phs001416_c1'),(0x7307884FD42D4F468BAA95D2797C5D95,'FENCE_phs000285_c2','FENCE role FENCE_phs000285_c2'),(0x731BE05E46A44978BE466AB074EF7173,'FENCE_phs001416_c2','FENCE role FENCE_phs001416_c2'),(0x7D22C56DD6194805A9CBAAC6FC00DB17,'FENCE_phs001466_c2','FENCE role FENCE_phs001466_c2'),(0x81B01D0768B6459E9DBB8FEAB03C34F7,'FENCE_phs000921_c999','FENCE role FENCE_phs000921_c999'),(0x86DF6EA130D047048E2320CBB6E8523D,'FENCE_phs001402_c1','FENCE role FENCE_phs001402_c1'),(0x89831BF935D54C908D1F12DA4321D71E,'FENCE_phs000964_c4','FENCE role FENCE_phs000964_c4'),(0x96AC2F5FB672443EA3DC37C68BDA0A5E,'FENCE_phs001368_c999','FENCE role FENCE_phs001368_c999'),(0x9FA39A046C2842458F8F57E34755597E,'FENCE_phs000974_c2','FENCE role FENCE_phs000974_c2'),(0xA172B259A9DC4143B009AAE6CC28237B,'FENCE_phs001368_c3','FENCE role FENCE_phs001368_c3'),(0xA5CEAF09FA6E4CB7984EE482C01E34FF,'FENCE_phs001217_c1','FENCE role FENCE_phs001217_c1'),(0xA5E998FDE3154DB2B2A4EA78B31ED6DB,'FENCE_phs001024_c999','FENCE role FENCE_phs001024_c999'),(0xB0096B12FEC841C8BCB8D5882E66209E,'FENCE_phs001466_c1','FENCE role FENCE_phs001466_c1'),(0xB42FB6A52BFD4E218337F2F5EFA18289,'FENCE_phs000920_c999','FENCE role FENCE_phs000920_c999'),(0xB65414BD442747559541703B35716D32,'FENCE_phs000920_c2','FENCE role FENCE_phs000920_c2'),(0xB6B20127F4CD45979331A79A81DC25EF,'FENCE_phs001368_c4','FENCE role FENCE_phs001368_c4'),(0xB73662D0813447A89BF26884774B8777,'FENCE_phs000951_c999','FENCE role FENCE_phs000951_c999'),(0xB91CC79101D24468A1283CF2F588E904,'FENCE_phs001368_c1','FENCE role FENCE_phs001368_c1'),(0xBE0578799D5A43AA963A16BBCF311D72,'FENCE_phs000810_c2','FENCE role FENCE_phs000810_c2'),(0xBF09363F47FE46B3A593C779B4F4894B,'FENCE_phs001218_c2','FENCE role FENCE_phs001218_c2'),(0xC8EFABA9C6D24ECD8E834EA4E6F7AE86,'FENCE_phs001345_c999','FENCE role FENCE_phs001345_c999'),(0xC972363B8E0842DDAD20AD1775AD33FB,'FENCE_phs001062_c1','FENCE role FENCE_phs001062_c1'),(0xCB8C34304603404685E14337DCF83D3A,'FENCE_phs000964_c3','FENCE role FENCE_phs000964_c3'),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,'FENCE_topmed','FENCE role FENCE_topmed'),(0xCC7E4C7BC8CE47D4B315C23978DC8A66,'FENCE_phs001435_c999','FENCE role FENCE_phs001435_c999'),(0xCF3106323154481B83C8140D25E11B4D,'FENCE_phs000972_c1','FENCE role FENCE_phs000972_c1'),(0xD82CDDC145AF4C97A33F6E8B76B0DF85,'FENCE_phs001416_c999','FENCE role FENCE_phs001416_c999'),(0xE0E5C5D047F242C2B6D7D54CE56A82D3,'FENCE_phs000964_c1','FENCE role FENCE_phs000964_c1'),(0xE22AF36E63314F47BDE2D0E4BCEE0D95,'FENCE_phs001359_c1','FENCE role FENCE_phs001359_c1'),(0xE2474A405A684AB2971EDFA6B5373F7F,'FENCE_phs000964_c2','FENCE role FENCE_phs000964_c2'),(0xE4C2B76D1EF043DE979C081AA98F989D,'FENCE_phs001466_c999','FENCE role FENCE_phs001466_c999'),(0xE581D75A40634A78998775E213CCEA03,'FENCE_phs001062_c2','FENCE role FENCE_phs001062_c2'),(0xE97C56A805414C72A059C51E6AB1B365,'FENCE_phs001345_c1','FENCE role FENCE_phs001345_c1'),(0xED0D3E03354441EE8C1FC9B2F04ED214,'FENCE_phs001402_c999','FENCE role FENCE_phs001402_c999'),(0xED815D2C179A11EABA2F0242C0A81002,'FENCE_phs000280_c1','For study Atherosclerosis Risk in Communities (ARIC) Cohort'),(0xED82C61C179A11EABA2F0242C0A81002,'FENCE_phs000280_c2','For study Atherosclerosis Risk in Communities (ARIC) Cohort'),(0xED8C0319179A11EABA2F0242C0A81002,'FENCE_phs000287_c1','For study Cardiovascular Health Study (CHS) Cohort'),(0xED8D346D179A11EABA2F0242C0A81002,'FENCE_phs000287_c2','For study Cardiovascular Health Study (CHS) Cohort'),(0xED8E417B179A11EABA2F0242C0A81002,'FENCE_phs000287_c3','For study Cardiovascular Health Study (CHS) Cohort'),(0xED8F4807179A11EABA2F0242C0A81002,'FENCE_phs000287_c4','For study Cardiovascular Health Study (CHS) Cohort'),(0xED997787179A11EABA2F0242C0A81002,'FENCE_phs000007_c1','For study Framingham Cohort'),(0xED9A828F179A11EABA2F0242C0A81002,'FENCE_phs000007_c2','For study Framingham Cohort'),(0xEDA8A762179A11EABA2F0242C0A81002,'FENCE_phs001074_c2','For study GeneSTAR NextGen Functional Genomics of Platelet Aggregation'),(0xEDB1C474179A11EABA2F0242C0A81002,'FENCE_phs001180_c2','For study Genes-Environments and Admixture in Latino Asthmatics (GALA II) Study'),(0xEDB59E7A179A11EABA2F0242C0A81002,'FENCE_phs001238_c1','For study Genetic Epidemiology Network of Arteriopathy (GENOA)'),(0xEDBE9242179A11EABA2F0242C0A81002,'FENCE_phs000784_c1','For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)'),(0xEDC7A86B179A11EABA2F0242C0A81002,'FENCE_phs000179_c1','For study Genetic Epidemiology of COPD (COPDGene)'),(0xEDC8B563179A11EABA2F0242C0A81002,'FENCE_phs000179_c2','For study Genetic Epidemiology of COPD (COPDGene)'),(0xEDD0DD2A179A11EABA2F0242C0A81002,'FENCE_phs000741_c1','For study Genetics of Lipid Lowering Drugs and Diet Network (GOLDN) Lipidomics Study'),(0xEDDE7FF0179A11EABA2F0242C0A81002,'FENCE_phs000914_c1','For study Genome-wide Association Study of Adiposity in Samoans'),(0xEDE2F13C179A11EABA2F0242C0A81002,'FENCE_phs001013_c1','For study Heart and Vascular Health Study (HVH)'),(0xEDE43A77179A11EABA2F0242C0A81002,'FENCE_phs001013_c2','For study Heart and Vascular Health Study (HVH)'),(0xEDEC7F35179A11EABA2F0242C0A81002,'FENCE_phs001001_c1','For study MGH Atrial Fibrillation Study'),(0xEDED9523179A11EABA2F0242C0A81002,'FENCE_phs001001_c2','For study MGH Atrial Fibrillation Study'),(0xEDF65B5D179A11EABA2F0242C0A81002,'FENCE_phs000209_c1','For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort'),(0xEDF79100179A11EABA2F0242C0A81002,'FENCE_phs000209_c2','For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort'),(0xEE058C86179A11EABA2F0242C0A81002,'FENCE_phs000289_c1','For study NHGRI Genome-Wide Association Study of Venous Thromboembolism (GWAS of VTE)'),(0xEE0A2CE2179A11EABA2F0242C0A81002,'FENCE_phs000284_c1','For study NHLBI Cleveland Family Study (CFS) Candidate Gene Association Resource (CARe)'),(0xEE133F30179A11EABA2F0242C0A81002,'FENCE_phs001207_c1','For study NHLBI TOPMed: African American Sarcoidosis Genetics Resource'),(0xEE184B3A179A11EABA2F0242C0A81002,'FENCE_phs000946_c1','For study NHLBI TOPMed: Boston Early-Onset COPD Study in the TOPMed Program'),(0xEE1CE8EB179A11EABA2F0242C0A81002,'FENCE_phs001412_c1','For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)'),(0xEE1E00B0179A11EABA2F0242C0A81002,'FENCE_phs001412_c2','For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)'),(0xEE22A0EE179A11EABA2F0242C0A81002,'FENCE_phs000956_c2','For study NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish'),(0xEE262842179A11EABA2F0242C0A81002,'FENCE_phs001293_c1','For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy'),(0xEE2741D3179A11EABA2F0242C0A81002,'FENCE_phs001293_c2','For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy'),(0xEE2AA66E179A11EABA2F0242C0A81002,'FENCE_phs001040_c1','For study NHLBI TOPMed: Novel Risk Factors for the Development of Atrial Fibrillation in Women'),(0xEE2F715D179A11EABA2F0242C0A81002,'FENCE_phs001024_c1','For study NHLBI TOPMed: Partners HealthCare Biobank'),(0xEE36B8FE179A11EABA2F0242C0A81002,'FENCE_phs001387_c3','For study NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)'),(0xEE393F22179A11EABA2F0242C0A81002,'FENCE_phs001215_c1','For study NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)'),(0xEE3F0842179A11EABA2F0242C0A81002,'FENCE_phs000921_c2','For study NHLBI TOPMed: Study of African Americans, Asthma, Genes and Environment (SAGE) Study'),(0xEE4279B8179A11EABA2F0242C0A81002,'FENCE_phs000988_c1','For study NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica'),(0xEE470AB7179A11EABA2F0242C0A81002,'FENCE_phs001143_c1','For study NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados'),(0xEE4BCE1D179A11EABA2F0242C0A81002,'FENCE_phs000997_c1','For study NHLBI TOPMed: The Vanderbilt AF Ablation Registry'),(0xEE505A56179A11EABA2F0242C0A81002,'FENCE_phs001032_c1','For study NHLBI TOPMed: The Vanderbilt Atrial Fibrillation Registry'),(0xEE54E5B2179A11EABA2F0242C0A81002,'FENCE_phs000286_c1','For study The Jackson Heart Study (JHS)'),(0xEE560149179A11EABA2F0242C0A81002,'FENCE_phs000286_c2','For study The Jackson Heart Study (JHS)'),(0xEE572477179A11EABA2F0242C0A81002,'FENCE_phs000286_c3','For study The Jackson Heart Study (JHS)'),(0xEE5834CA179A11EABA2F0242C0A81002,'FENCE_phs000286_c4','For study The Jackson Heart Study (JHS)'),(0xEE62C641179A11EABA2F0242C0A81002,'FENCE_phs000200_c1','For study Women`s Health Initiative'),(0xEE63D887179A11EABA2F0242C0A81002,'FENCE_phs000200_c2','For study Women`s Health Initiative'),(0xFD0419B901124BD2B8E0C6A3940D203F,'FENCE_phs000993_c2','FENCE role FENCE_phs000993_c2'),(0xFF047893ED024F05BE0443E5F3E3EA76,'FENCE_phs000810_c1','FENCE role FENCE_phs000810_c1');
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
INSERT INTO `role_privilege` VALUES (0x002DC366B0D8420F998F885D0ED797FD,0x7044061AF65B425F86CE73A1BF7F4402),(0x002DC366B0D8420F998F885D0ED797FD,0xAD08212E096F414CBA8D1BAE09415DAB),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xED81AAB8179A11EABA2F0242C0A81002),(0xED815D2C179A11EABA2F0242C0A81002,0xED81AAB8179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xED830599179A11EABA2F0242C0A81002),(0xED82C61C179A11EABA2F0242C0A81002,0xED830599179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xED8C37A9179A11EABA2F0242C0A81002),(0xED8C0319179A11EABA2F0242C0A81002,0xED8C37A9179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xED8D687C179A11EABA2F0242C0A81002),(0xED8D346D179A11EABA2F0242C0A81002,0xED8D687C179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xED8E7903179A11EABA2F0242C0A81002),(0xED8E417B179A11EABA2F0242C0A81002,0xED8E7903179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xED8F7F1A179A11EABA2F0242C0A81002),(0xED8F4807179A11EABA2F0242C0A81002,0xED8F7F1A179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xED99ACEF179A11EABA2F0242C0A81002),(0xED997787179A11EABA2F0242C0A81002,0xED99ACEF179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xED9AB7F1179A11EABA2F0242C0A81002),(0xED9A828F179A11EABA2F0242C0A81002,0xED9AB7F1179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDA8DB41179A11EABA2F0242C0A81002),(0xEDA8A762179A11EABA2F0242C0A81002,0xEDA8DB41179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDB20308179A11EABA2F0242C0A81002),(0xEDB1C474179A11EABA2F0242C0A81002,0xEDB20308179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDB5D5DC179A11EABA2F0242C0A81002),(0xEDB59E7A179A11EABA2F0242C0A81002,0xEDB5D5DC179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDBED577179A11EABA2F0242C0A81002),(0xEDBE9242179A11EABA2F0242C0A81002,0xEDBED577179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDC7DD70179A11EABA2F0242C0A81002),(0xEDC7A86B179A11EABA2F0242C0A81002,0xEDC7DD70179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDC8F07E179A11EABA2F0242C0A81002),(0xEDC8B563179A11EABA2F0242C0A81002,0xEDC8F07E179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDD113CB179A11EABA2F0242C0A81002),(0xEDD0DD2A179A11EABA2F0242C0A81002,0xEDD113CB179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDDEB790179A11EABA2F0242C0A81002),(0xEDDE7FF0179A11EABA2F0242C0A81002,0xEDDEB790179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDE327B5179A11EABA2F0242C0A81002),(0xEDE2F13C179A11EABA2F0242C0A81002,0xEDE327B5179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDE473BD179A11EABA2F0242C0A81002),(0xEDE43A77179A11EABA2F0242C0A81002,0xEDE473BD179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDECB40A179A11EABA2F0242C0A81002),(0xEDEC7F35179A11EABA2F0242C0A81002,0xEDECB40A179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDEDD88F179A11EABA2F0242C0A81002),(0xEDED9523179A11EABA2F0242C0A81002,0xEDEDD88F179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDF69116179A11EABA2F0242C0A81002),(0xEDF65B5D179A11EABA2F0242C0A81002,0xEDF69116179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEDF7C811179A11EABA2F0242C0A81002),(0xEDF79100179A11EABA2F0242C0A81002,0xEDF7C811179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE05C175179A11EABA2F0242C0A81002),(0xEE058C86179A11EABA2F0242C0A81002,0xEE05C175179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE0A61A8179A11EABA2F0242C0A81002),(0xEE0A2CE2179A11EABA2F0242C0A81002,0xEE0A61A8179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE13752E179A11EABA2F0242C0A81002),(0xEE133F30179A11EABA2F0242C0A81002,0xEE13752E179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE188DDE179A11EABA2F0242C0A81002),(0xEE184B3A179A11EABA2F0242C0A81002,0xEE188DDE179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE1D1E5C179A11EABA2F0242C0A81002),(0xEE1CE8EB179A11EABA2F0242C0A81002,0xEE1D1E5C179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE1E3757179A11EABA2F0242C0A81002),(0xEE1E00B0179A11EABA2F0242C0A81002,0xEE1E3757179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE22DD87179A11EABA2F0242C0A81002),(0xEE22A0EE179A11EABA2F0242C0A81002,0xEE22DD87179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE2660F5179A11EABA2F0242C0A81002),(0xEE262842179A11EABA2F0242C0A81002,0xEE2660F5179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE277A5C179A11EABA2F0242C0A81002),(0xEE2741D3179A11EABA2F0242C0A81002,0xEE277A5C179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE2ADBEE179A11EABA2F0242C0A81002),(0xEE2AA66E179A11EABA2F0242C0A81002,0xEE2ADBEE179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE2FAFCE179A11EABA2F0242C0A81002),(0xEE2F715D179A11EABA2F0242C0A81002,0xEE2FAFCE179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE36F02D179A11EABA2F0242C0A81002),(0xEE36B8FE179A11EABA2F0242C0A81002,0xEE36F02D179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE3976FD179A11EABA2F0242C0A81002),(0xEE393F22179A11EABA2F0242C0A81002,0xEE3976FD179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE3F4223179A11EABA2F0242C0A81002),(0xEE3F0842179A11EABA2F0242C0A81002,0xEE3F4223179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE42ADEC179A11EABA2F0242C0A81002),(0xEE4279B8179A11EABA2F0242C0A81002,0xEE42ADEC179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE473FD1179A11EABA2F0242C0A81002),(0xEE470AB7179A11EABA2F0242C0A81002,0xEE473FD1179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE4C0411179A11EABA2F0242C0A81002),(0xEE4BCE1D179A11EABA2F0242C0A81002,0xEE4C0411179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE509643179A11EABA2F0242C0A81002),(0xEE505A56179A11EABA2F0242C0A81002,0xEE509643179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE551CBA179A11EABA2F0242C0A81002),(0xEE54E5B2179A11EABA2F0242C0A81002,0xEE551CBA179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE563C06179A11EABA2F0242C0A81002),(0xEE560149179A11EABA2F0242C0A81002,0xEE563C06179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE575782179A11EABA2F0242C0A81002),(0xEE572477179A11EABA2F0242C0A81002,0xEE575782179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE586B72179A11EABA2F0242C0A81002),(0xEE5834CA179A11EABA2F0242C0A81002,0xEE586B72179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE62FE9D179A11EABA2F0242C0A81002),(0xEE62C641179A11EABA2F0242C0A81002,0xEE62FE9D179A11EABA2F0242C0A81002),(0xCBE74D54905E41FFB7CAB936A7AD0D2F,0xEE640CE8179A11EABA2F0242C0A81002),(0xEE63D887179A11EABA2F0242C0A81002,0xEE640CE8179A11EABA2F0242C0A81002);
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
INSERT INTO `user_role` VALUES (0x7122BA09414B427DB8F0E91394490904,0x04AAAD4320F847F68FCAE27428996C20),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x04AAAD4320F847F68FCAE27428996C20),(0x86076C141BA2454A81D979F1E89FB21C,0x04AAAD4320F847F68FCAE27428996C20),(0xA2D347F3E67942C58D3806CF65DE455E,0x04AAAD4320F847F68FCAE27428996C20),(0x7122BA09414B427DB8F0E91394490904,0x082ECA1321144089B524F372C5616BC1),(0x5DF1D219D00B4937BE9B71016F908DCB,0x09354B07C6A247CC8D90B85644D3E526),(0x7122BA09414B427DB8F0E91394490904,0x09354B07C6A247CC8D90B85644D3E526),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x09354B07C6A247CC8D90B85644D3E526),(0x86076C141BA2454A81D979F1E89FB21C,0x09354B07C6A247CC8D90B85644D3E526),(0xA2D347F3E67942C58D3806CF65DE455E,0x09354B07C6A247CC8D90B85644D3E526),(0xEB529E13BC694135A6E0871EA0B6BB62,0x09354B07C6A247CC8D90B85644D3E526),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x167BF7DC7EC24502B0B1957C5D4FAA42),(0x86076C141BA2454A81D979F1E89FB21C,0x167BF7DC7EC24502B0B1957C5D4FAA42),(0xA2D347F3E67942C58D3806CF65DE455E,0x167BF7DC7EC24502B0B1957C5D4FAA42),(0x7122BA09414B427DB8F0E91394490904,0x1C298F8E196842F1A983B4EE7432861F),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x318E5DDD9980437E99BBEDE8D1C18D50),(0x86076C141BA2454A81D979F1E89FB21C,0x318E5DDD9980437E99BBEDE8D1C18D50),(0xA2D347F3E67942C58D3806CF65DE455E,0x318E5DDD9980437E99BBEDE8D1C18D50),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x31DCF75BED384463B8E9D46EE61EACA9),(0x86076C141BA2454A81D979F1E89FB21C,0x31DCF75BED384463B8E9D46EE61EACA9),(0xA2D347F3E67942C58D3806CF65DE455E,0x31DCF75BED384463B8E9D46EE61EACA9),(0x7122BA09414B427DB8F0E91394490904,0x32A1992174BD4AE5AAC7D12191423708),(0x5DF1D219D00B4937BE9B71016F908DCB,0x474329AB20014E96B57C94B7AE22B835),(0x7122BA09414B427DB8F0E91394490904,0x474329AB20014E96B57C94B7AE22B835),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x474329AB20014E96B57C94B7AE22B835),(0x86076C141BA2454A81D979F1E89FB21C,0x474329AB20014E96B57C94B7AE22B835),(0xA2D347F3E67942C58D3806CF65DE455E,0x474329AB20014E96B57C94B7AE22B835),(0xEB529E13BC694135A6E0871EA0B6BB62,0x474329AB20014E96B57C94B7AE22B835),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x4C00728449BA49B7A987A0EC78C5C0AF),(0x86076C141BA2454A81D979F1E89FB21C,0x4C00728449BA49B7A987A0EC78C5C0AF),(0xA2D347F3E67942C58D3806CF65DE455E,0x4C00728449BA49B7A987A0EC78C5C0AF),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x54467DFA6B724F649C5CDF20681A68AE),(0x86076C141BA2454A81D979F1E89FB21C,0x54467DFA6B724F649C5CDF20681A68AE),(0xA2D347F3E67942C58D3806CF65DE455E,0x54467DFA6B724F649C5CDF20681A68AE),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x59ABE7BF3CA94CEC815D1C8DEB008EA2),(0x86076C141BA2454A81D979F1E89FB21C,0x59ABE7BF3CA94CEC815D1C8DEB008EA2),(0xA2D347F3E67942C58D3806CF65DE455E,0x59ABE7BF3CA94CEC815D1C8DEB008EA2),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x5AA9EE2FB2394F1186ACB89AA8FFB1E7),(0x86076C141BA2454A81D979F1E89FB21C,0x5AA9EE2FB2394F1186ACB89AA8FFB1E7),(0xA2D347F3E67942C58D3806CF65DE455E,0x5AA9EE2FB2394F1186ACB89AA8FFB1E7),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x5C5E5A026B88470891681093B480E24B),(0x86076C141BA2454A81D979F1E89FB21C,0x5C5E5A026B88470891681093B480E24B),(0xA2D347F3E67942C58D3806CF65DE455E,0x5C5E5A026B88470891681093B480E24B),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x5F08AD0F91254B66B4AD91488D5C7BF0),(0x86076C141BA2454A81D979F1E89FB21C,0x5F08AD0F91254B66B4AD91488D5C7BF0),(0xA2D347F3E67942C58D3806CF65DE455E,0x5F08AD0F91254B66B4AD91488D5C7BF0),(0x7122BA09414B427DB8F0E91394490904,0x701B7E1B292A44A0BB6724102CA94C39),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x701B7E1B292A44A0BB6724102CA94C39),(0x86076C141BA2454A81D979F1E89FB21C,0x701B7E1B292A44A0BB6724102CA94C39),(0xA2D347F3E67942C58D3806CF65DE455E,0x701B7E1B292A44A0BB6724102CA94C39),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x7307884FD42D4F468BAA95D2797C5D95),(0x86076C141BA2454A81D979F1E89FB21C,0x7307884FD42D4F468BAA95D2797C5D95),(0xA2D347F3E67942C58D3806CF65DE455E,0x7307884FD42D4F468BAA95D2797C5D95),(0x7122BA09414B427DB8F0E91394490904,0x731BE05E46A44978BE466AB074EF7173),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x731BE05E46A44978BE466AB074EF7173),(0x86076C141BA2454A81D979F1E89FB21C,0x731BE05E46A44978BE466AB074EF7173),(0xA2D347F3E67942C58D3806CF65DE455E,0x731BE05E46A44978BE466AB074EF7173),(0x7122BA09414B427DB8F0E91394490904,0x7D22C56DD6194805A9CBAAC6FC00DB17),(0x7122BA09414B427DB8F0E91394490904,0x81B01D0768B6459E9DBB8FEAB03C34F7),(0x7122BA09414B427DB8F0E91394490904,0x86DF6EA130D047048E2320CBB6E8523D),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x86DF6EA130D047048E2320CBB6E8523D),(0x86076C141BA2454A81D979F1E89FB21C,0x86DF6EA130D047048E2320CBB6E8523D),(0xA2D347F3E67942C58D3806CF65DE455E,0x86DF6EA130D047048E2320CBB6E8523D),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x89831BF935D54C908D1F12DA4321D71E),(0x86076C141BA2454A81D979F1E89FB21C,0x89831BF935D54C908D1F12DA4321D71E),(0xA2D347F3E67942C58D3806CF65DE455E,0x89831BF935D54C908D1F12DA4321D71E),(0x7122BA09414B427DB8F0E91394490904,0x96AC2F5FB672443EA3DC37C68BDA0A5E),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0x9FA39A046C2842458F8F57E34755597E),(0x86076C141BA2454A81D979F1E89FB21C,0x9FA39A046C2842458F8F57E34755597E),(0xA2D347F3E67942C58D3806CF65DE455E,0x9FA39A046C2842458F8F57E34755597E),(0x7122BA09414B427DB8F0E91394490904,0xA172B259A9DC4143B009AAE6CC28237B),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xA5CEAF09FA6E4CB7984EE482C01E34FF),(0x86076C141BA2454A81D979F1E89FB21C,0xA5CEAF09FA6E4CB7984EE482C01E34FF),(0xA2D347F3E67942C58D3806CF65DE455E,0xA5CEAF09FA6E4CB7984EE482C01E34FF),(0x7122BA09414B427DB8F0E91394490904,0xA5E998FDE3154DB2B2A4EA78B31ED6DB),(0x7122BA09414B427DB8F0E91394490904,0xB0096B12FEC841C8BCB8D5882E66209E),(0x7122BA09414B427DB8F0E91394490904,0xB42FB6A52BFD4E218337F2F5EFA18289),(0x7122BA09414B427DB8F0E91394490904,0xB65414BD442747559541703B35716D32),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xB65414BD442747559541703B35716D32),(0x86076C141BA2454A81D979F1E89FB21C,0xB65414BD442747559541703B35716D32),(0xA2D347F3E67942C58D3806CF65DE455E,0xB65414BD442747559541703B35716D32),(0x7122BA09414B427DB8F0E91394490904,0xB6B20127F4CD45979331A79A81DC25EF),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xB6B20127F4CD45979331A79A81DC25EF),(0x86076C141BA2454A81D979F1E89FB21C,0xB6B20127F4CD45979331A79A81DC25EF),(0xA2D347F3E67942C58D3806CF65DE455E,0xB6B20127F4CD45979331A79A81DC25EF),(0x7122BA09414B427DB8F0E91394490904,0xB73662D0813447A89BF26884774B8777),(0x7122BA09414B427DB8F0E91394490904,0xB91CC79101D24468A1283CF2F588E904),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xB91CC79101D24468A1283CF2F588E904),(0x86076C141BA2454A81D979F1E89FB21C,0xB91CC79101D24468A1283CF2F588E904),(0xA2D347F3E67942C58D3806CF65DE455E,0xB91CC79101D24468A1283CF2F588E904),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xBE0578799D5A43AA963A16BBCF311D72),(0x86076C141BA2454A81D979F1E89FB21C,0xBE0578799D5A43AA963A16BBCF311D72),(0xA2D347F3E67942C58D3806CF65DE455E,0xBE0578799D5A43AA963A16BBCF311D72),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xBF09363F47FE46B3A593C779B4F4894B),(0x86076C141BA2454A81D979F1E89FB21C,0xBF09363F47FE46B3A593C779B4F4894B),(0xA2D347F3E67942C58D3806CF65DE455E,0xBF09363F47FE46B3A593C779B4F4894B),(0x7122BA09414B427DB8F0E91394490904,0xC8EFABA9C6D24ECD8E834EA4E6F7AE86),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xC972363B8E0842DDAD20AD1775AD33FB),(0x86076C141BA2454A81D979F1E89FB21C,0xC972363B8E0842DDAD20AD1775AD33FB),(0xA2D347F3E67942C58D3806CF65DE455E,0xC972363B8E0842DDAD20AD1775AD33FB),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xCB8C34304603404685E14337DCF83D3A),(0x86076C141BA2454A81D979F1E89FB21C,0xCB8C34304603404685E14337DCF83D3A),(0xA2D347F3E67942C58D3806CF65DE455E,0xCB8C34304603404685E14337DCF83D3A),(0x0B673F43F02E45678954E3ECE47817A5,0xCBE74D54905E41FFB7CAB936A7AD0D2F),(0x2B77D35AD8F94B05BEBABC6846C874C4,0xCBE74D54905E41FFB7CAB936A7AD0D2F),(0x3B50372C1CFC4FFFBDC4EC91827AF1E6,0xCBE74D54905E41FFB7CAB936A7AD0D2F),(0x5BB0890FD3494EC1B39FB69B5C144516,0xCBE74D54905E41FFB7CAB936A7AD0D2F),(0x9DE7A06475204FF5B1D0D474993BB0CC,0xCBE74D54905E41FFB7CAB936A7AD0D2F),(0xD276B2E6C1A44519944D5A4BB4499E70,0xCBE74D54905E41FFB7CAB936A7AD0D2F),(0xD9F6814C042942E7BBBE5FBD3CCAB416,0xCBE74D54905E41FFB7CAB936A7AD0D2F),(0x7122BA09414B427DB8F0E91394490904,0xCC7E4C7BC8CE47D4B315C23978DC8A66),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xCF3106323154481B83C8140D25E11B4D),(0x86076C141BA2454A81D979F1E89FB21C,0xCF3106323154481B83C8140D25E11B4D),(0xA2D347F3E67942C58D3806CF65DE455E,0xCF3106323154481B83C8140D25E11B4D),(0x7122BA09414B427DB8F0E91394490904,0xD82CDDC145AF4C97A33F6E8B76B0DF85),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xE0E5C5D047F242C2B6D7D54CE56A82D3),(0x86076C141BA2454A81D979F1E89FB21C,0xE0E5C5D047F242C2B6D7D54CE56A82D3),(0xA2D347F3E67942C58D3806CF65DE455E,0xE0E5C5D047F242C2B6D7D54CE56A82D3),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xE22AF36E63314F47BDE2D0E4BCEE0D95),(0x86076C141BA2454A81D979F1E89FB21C,0xE22AF36E63314F47BDE2D0E4BCEE0D95),(0xA2D347F3E67942C58D3806CF65DE455E,0xE22AF36E63314F47BDE2D0E4BCEE0D95),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xE2474A405A684AB2971EDFA6B5373F7F),(0x86076C141BA2454A81D979F1E89FB21C,0xE2474A405A684AB2971EDFA6B5373F7F),(0xA2D347F3E67942C58D3806CF65DE455E,0xE2474A405A684AB2971EDFA6B5373F7F),(0x7122BA09414B427DB8F0E91394490904,0xE4C2B76D1EF043DE979C081AA98F989D),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xE581D75A40634A78998775E213CCEA03),(0x86076C141BA2454A81D979F1E89FB21C,0xE581D75A40634A78998775E213CCEA03),(0xA2D347F3E67942C58D3806CF65DE455E,0xE581D75A40634A78998775E213CCEA03),(0x7122BA09414B427DB8F0E91394490904,0xE97C56A805414C72A059C51E6AB1B365),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xE97C56A805414C72A059C51E6AB1B365),(0x86076C141BA2454A81D979F1E89FB21C,0xE97C56A805414C72A059C51E6AB1B365),(0xA2D347F3E67942C58D3806CF65DE455E,0xE97C56A805414C72A059C51E6AB1B365),(0x7122BA09414B427DB8F0E91394490904,0xED0D3E03354441EE8C1FC9B2F04ED214),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xED815D2C179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xED815D2C179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xED815D2C179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xED82C61C179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xED82C61C179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xED82C61C179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xED8C0319179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xED8C0319179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xED8C0319179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xED8D346D179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xED8D346D179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xED8D346D179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xED8E417B179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xED8E417B179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xED8E417B179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xED8F4807179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xED8F4807179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xED8F4807179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xED997787179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xED997787179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xED997787179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xED9A828F179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xED9A828F179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xED9A828F179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDA8A762179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDA8A762179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDA8A762179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDB1C474179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDB1C474179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDB1C474179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDB59E7A179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDB59E7A179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDB59E7A179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDBE9242179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDBE9242179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDBE9242179A11EABA2F0242C0A81002),(0x5DF1D219D00B4937BE9B71016F908DCB,0xEDC7A86B179A11EABA2F0242C0A81002),(0x7122BA09414B427DB8F0E91394490904,0xEDC7A86B179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDC7A86B179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDC7A86B179A11EABA2F0242C0A81002),(0x97BE390B45E24828B73E05B64A74F23E,0xEDC7A86B179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDC7A86B179A11EABA2F0242C0A81002),(0xEB529E13BC694135A6E0871EA0B6BB62,0xEDC7A86B179A11EABA2F0242C0A81002),(0x5DF1D219D00B4937BE9B71016F908DCB,0xEDC8B563179A11EABA2F0242C0A81002),(0x7122BA09414B427DB8F0E91394490904,0xEDC8B563179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDC8B563179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDC8B563179A11EABA2F0242C0A81002),(0x97BE390B45E24828B73E05B64A74F23E,0xEDC8B563179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDC8B563179A11EABA2F0242C0A81002),(0xEB529E13BC694135A6E0871EA0B6BB62,0xEDC8B563179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDD0DD2A179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDD0DD2A179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDD0DD2A179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDDE7FF0179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDDE7FF0179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDDE7FF0179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDE2F13C179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDE2F13C179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDE2F13C179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDE43A77179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDE43A77179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDE43A77179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDEC7F35179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDEC7F35179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDEC7F35179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDED9523179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDED9523179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDED9523179A11EABA2F0242C0A81002),(0x7122BA09414B427DB8F0E91394490904,0xEDF65B5D179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDF65B5D179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDF65B5D179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDF65B5D179A11EABA2F0242C0A81002),(0x7122BA09414B427DB8F0E91394490904,0xEDF79100179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEDF79100179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEDF79100179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEDF79100179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE0A2CE2179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE0A2CE2179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE0A2CE2179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE133F30179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE133F30179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE133F30179A11EABA2F0242C0A81002),(0x7122BA09414B427DB8F0E91394490904,0xEE184B3A179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE184B3A179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE184B3A179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE184B3A179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE1CE8EB179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE1CE8EB179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE1CE8EB179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE1E00B0179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE1E00B0179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE1E00B0179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE22A0EE179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE22A0EE179A11EABA2F0242C0A81002),(0x97BE390B45E24828B73E05B64A74F23E,0xEE22A0EE179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE22A0EE179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE262842179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE262842179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE262842179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE2741D3179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE2741D3179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE2741D3179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE2AA66E179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE2AA66E179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE2AA66E179A11EABA2F0242C0A81002),(0x7122BA09414B427DB8F0E91394490904,0xEE2F715D179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE2F715D179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE2F715D179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE2F715D179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE36B8FE179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE36B8FE179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE36B8FE179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE393F22179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE393F22179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE393F22179A11EABA2F0242C0A81002),(0x7122BA09414B427DB8F0E91394490904,0xEE3F0842179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE3F0842179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE3F0842179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE3F0842179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE4279B8179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE4279B8179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE4279B8179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE470AB7179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE470AB7179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE470AB7179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE4BCE1D179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE4BCE1D179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE4BCE1D179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE505A56179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE505A56179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE505A56179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE54E5B2179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE54E5B2179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE54E5B2179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE560149179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE560149179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE560149179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE572477179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE572477179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE572477179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE5834CA179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE5834CA179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE5834CA179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE62C641179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE62C641179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE62C641179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xEE63D887179A11EABA2F0242C0A81002),(0x86076C141BA2454A81D979F1E89FB21C,0xEE63D887179A11EABA2F0242C0A81002),(0xA2D347F3E67942C58D3806CF65DE455E,0xEE63D887179A11EABA2F0242C0A81002),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xFD0419B901124BD2B8E0C6A3940D203F),(0x86076C141BA2454A81D979F1E89FB21C,0xFD0419B901124BD2B8E0C6A3940D203F),(0xA2D347F3E67942C58D3806CF65DE455E,0xFD0419B901124BD2B8E0C6A3940D203F),(0x80DB70CAA1C54B20A9AE96B1F809FDD9,0xFF047893ED024F05BE0443E5F3E3EA76),(0x86076C141BA2454A81D979F1E89FB21C,0xFF047893ED024F05BE0443E5F3E3EA76),(0xA2D347F3E67942C58D3806CF65DE455E,0xFF047893ED024F05BE0443E5F3E3EA76);
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000007.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000007.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000007.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000179.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000179.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000179.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      'FENCE_phs000200_c0',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000200_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000200.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000200_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000200.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000200_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000200.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000209.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000209.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000209.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000280.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000280.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000280.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000284.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000284.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      'FENCE_phs000285_c1',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000285_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000285.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000285_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000285.c1", 
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
      'FENCE_phs000285_c2',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000285_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000285.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000285_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000285.c2", 
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000286.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000286.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000286.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000286.c3"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000286.c4"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000287.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000287.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000287.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000287.c3"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000287.c4"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      'FENCE_phs000289_c0',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000289_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000289.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000289_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000289.c0", 
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
      'FENCE_phs000289_c1',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000289_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000289.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000289_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000289.c1", 
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
      'FENCE_phs000741_c0',
      'For study Genetics of Lipid Lowering Drugs and Diet Network (GOLDN) Lipidomics Study'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genetics of Lipid Lowering Drugs and Diet Network (GOLDN) Lipidomics Study', 
      'PRIV_FENCE_phs000741_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000741.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genetics of Lipid Lowering Drugs and Diet Network (GOLDN) Lipidomics Study\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000741_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000741.c0", 
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
      'FENCE_phs000741_c1',
      'For study Genetics of Lipid Lowering Drugs and Diet Network (GOLDN) Lipidomics Study'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genetics of Lipid Lowering Drugs and Diet Network (GOLDN) Lipidomics Study', 
      'PRIV_FENCE_phs000741_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000741.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genetics of Lipid Lowering Drugs and Diet Network (GOLDN) Lipidomics Study\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000741_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000741.c1", 
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
      'FENCE_phs000784_c0',
      'For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)', 
      'PRIV_FENCE_phs000784_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000784.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genetic Epidemiology Network of Salt Sensitivity (GenSalt)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000784_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000784.c0", 
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
      'FENCE_phs000784_c1',
      'For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)', 
      'PRIV_FENCE_phs000784_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000784.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\Genetic Epidemiology Network of Salt Sensitivity (GenSalt)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000784_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000784.c1", 
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
      'FENCE_phs000810_c1',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000810_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000810.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000810_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000810.c1", 
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
      'FENCE_phs000810_c2',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000810_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000810.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000810_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000810.c2", 
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
      'FENCE_phs000820_c1',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000820_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000820.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs000820_c1', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs000820.c1", 
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
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000914_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000914.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs000914_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000914.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000921.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Study of African Americans, Asthma, Genes and Environment (SAGE) Study\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000946.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Boston Early-Onset COPD Study in the TOPMed Program\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000956.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000956.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000988.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000988.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs000997.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Vanderbilt AF Ablation Registry\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001001.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001001.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001013.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001013.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001024.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Partners HealthCare Biobank\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001032.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Vanderbilt Atrial Fibrillation Registry\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      'FENCE_phs001040_c1',
      'For study NHLBI TOPMed: Novel Risk Factors for the Development of Atrial Fibrillation in Women'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: Novel Risk Factors for the Development of Atrial Fibrillation in Women', 
      'PRIV_FENCE_phs001040_c1', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001040.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Novel Risk Factors for the Development of Atrial Fibrillation in Women\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      'FENCE_phs001074_c0',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs001074_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001074.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001074_c0', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001074.c0", 
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
      'FENCE_phs001074_c2',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs001074_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001074.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
    );
            SET @uuidACCESSRULE = REPLACE(UUID(),'-','');
        INSERT INTO `access_rule` VALUES (
          unhex(@uuidACCESSRULE), 
          'AR_FENCE_phs001074_c2', 
          'AccessRule for only ', 
          "$..categoryFilters.['\\\\_Consents\\\\Short Study Accession with Consent Code\\\\']", 
          4,
          "phs001074.c2", 
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001143.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001143.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      'FENCE_phs001180_c0',
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs001180_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001180.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      'For study '
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study ', 
      'PRIV_FENCE_phs001180_c2', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001180.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      'FENCE_phs001207_c0',
      'For study NHLBI TOPMed: African American Sarcoidosis Genetics Resource'
    );
    
    SET @uuidPriv = REPLACE(UUID(),'-','');
    INSERT INTO privilege VALUES ( 
      unhex(@uuidPriv),
      'For study NHLBI TOPMed: African American Sarcoidosis Genetics Resource', 
      'PRIV_FENCE_phs001207_c0', 
      (SELECT uuid FROM application WHERE name ='PICSURE'), 
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001207.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: African American Sarcoidosis Genetics Resource\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001207.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: African American Sarcoidosis Genetics Resource\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001215.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001215.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001238.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001238.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001293.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001293.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001293.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001387.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001387.c3"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001412.c0"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001412.c1"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
      '{"categoryFilters": {"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\":["phs001412.c2"]},"numericFilters":{},"requiredFields":["\\\\_Study Accession with Patient ID\\\\"],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}',
      '["\\\\NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)\\\\","\\\\DCC Harmonized data set\\\\", "\\\\_"]'
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
    
delete from accessRule_privilege where accessRule_id = (select uuid from access_rule where name = 'AR_ONLY_QUERY');
 
