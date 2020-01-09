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
INSERT INTO `resource` VALUES (_binary '\â?RóTN‹™,\Ó|‹›¡@',NULL,'http://hpds.local:8080/PIC-SURE/','Basic HPDS resource','hpds',NULL);
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
INSERT INTO `application` VALUES (_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','PIC-SURE multiple data access API',_binary '','PICSURE','${picsure-token-introspection-token}','/picsureui');
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
INSERT INTO `connection` VALUES (_binary '\Ø\ÄV29C|•pm^VÊ¸','FENCE','fence','fence|','[{\"label\":\"email\",\"id\":\"email\"}]');
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
INSERT INTO `privilege` VALUES (_binary 'pD\Zö[B_†\Îs¡¿D','PIC-SURE Auth super admin for managing roles/privileges/application/connections','SUPER_ADMIN',NULL,NULL,NULL),(_binary '­!.	oALº®	A]«','PIC-SURE Auth admin for managing users.','ADMIN',NULL,NULL,NULL),(_binary 'íª¸š\êº/BÀ¨','For study Atherosclerosis Risk in Communities (ARIC) Cohort','PRIV_FENCE_phs000280_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000280.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Atherosclerosis_Risk_in_Communities_ARIC_Cohort\",\"DCC_Harmonized_data_set\"]'),(_binary '\íƒ™š\êº/BÀ¨','For study Atherosclerosis Risk in Communities (ARIC) Cohort','PRIV_FENCE_phs000280_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000280.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Atherosclerosis_Risk_in_Communities_ARIC_Cohort\",\"DCC_Harmonized_data_set\"]'),(_binary '\íŒ7©š\êº/BÀ¨','For study Cardiovascular Health Study (CHS) Cohort','PRIV_FENCE_phs000287_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000287.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Cardiovascular_Health_Study_CHS_Cohort\",\"DCC_Harmonized_data_set\"]'),(_binary '\íh|š\êº/BÀ¨','For study Cardiovascular Health Study (CHS) Cohort','PRIV_FENCE_phs000287_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000287.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Cardiovascular_Health_Study_CHS_Cohort\",\"DCC_Harmonized_data_set\"]'),(_binary '\íŽyš\êº/BÀ¨','For study Cardiovascular Health Study (CHS) Cohort','PRIV_FENCE_phs000287_c3',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000287.c3\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Cardiovascular_Health_Study_CHS_Cohort\",\"DCC_Harmonized_data_set\"]'),(_binary '\í\Zš\êº/BÀ¨','For study Cardiovascular Health Study (CHS) Cohort','PRIV_FENCE_phs000287_c4',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000287.c4\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Cardiovascular_Health_Study_CHS_Cohort\",\"DCC_Harmonized_data_set\"]'),(_binary 'í™¬\ïš\êº/BÀ¨','For study Framingham Cohort','PRIV_FENCE_phs000007_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000007.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Framingham_Cohort\",\"DCC_Harmonized_data_set\"]'),(_binary 'íš·ñš\êº/BÀ¨','For study Framingham Cohort','PRIV_FENCE_phs000007_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000007.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Framingham_Cohort\",\"DCC_Harmonized_data_set\"]'),(_binary '\í¨\ÛAš\êº/BÀ¨','For study GeneSTAR NextGen Functional Genomics of Platelet Aggregation','PRIV_FENCE_phs001074_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001074.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"GeneSTAR_NextGen_Functional_Genomics_of_Platelet_Aggregation\",\"DCC_Harmonized_data_set\"]'),(_binary '\í²š\êº/BÀ¨','For study Genes-Environments and Admixture in Latino Asthmatics (GALA II) Study','PRIV_FENCE_phs001180_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001180.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genes_Environments_and_Admixture_in_Latino_Asthmatics_GALA_II_Study\",\"DCC_Harmonized_data_set\"]'),(_binary '\íµ\Õ\Üš\êº/BÀ¨','For study Genetic Epidemiology Network of Arteriopathy (GENOA)','PRIV_FENCE_phs001238_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001238.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genetic_Epidemiology_Network_of_Arteriopathy_GENOA_\",\"DCC_Harmonized_data_set\"]'),(_binary '\í¾\Õwš\êº/BÀ¨','For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)','PRIV_FENCE_phs000784_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000784.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genetic_Epidemiology_Network_of_Salt_Sensitivity_GenSalt_\",\"DCC_Harmonized_data_set\"]'),(_binary '\í\Ç\Ýpš\êº/BÀ¨','For study Genetic Epidemiology of COPD (COPDGene)','PRIV_FENCE_phs000179_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000179.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genetic_Epidemiology_of_COPD_COPDGene_\",\"DCC_Harmonized_data_set\"]'),(_binary '\í\Èð~š\êº/BÀ¨','For study Genetic Epidemiology of COPD (COPDGene)','PRIV_FENCE_phs000179_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000179.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genetic_Epidemiology_of_COPD_COPDGene_\",\"DCC_Harmonized_data_set\"]'),(_binary '\í\Ñ\Ëš\êº/BÀ¨','For study Genetics of Lipid Lowering Drugs and Diet Network (GOLDN) Lipidomics Study','PRIV_FENCE_phs000741_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000741.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genetics_of_Lipid_Lowering_Drugs_and_Diet_Network_GOLDN_Lipidomics_Study\",\"DCC_Harmonized_data_set\"]'),(_binary '\íÞ·š\êº/BÀ¨','For study Genome-wide Association Study of Adiposity in Samoans','PRIV_FENCE_phs000914_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000914.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Genome_wide_Association_Study_of_Adiposity_in_Samoans\",\"DCC_Harmonized_data_set\"]'),(_binary '\í\ã\'µš\êº/BÀ¨','For study Heart and Vascular Health Study (HVH)','PRIV_FENCE_phs001013_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001013.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Heart_and_Vascular_Health_Study_HVH_\",\"DCC_Harmonized_data_set\"]'),(_binary '\í\äs½š\êº/BÀ¨','For study Heart and Vascular Health Study (HVH)','PRIV_FENCE_phs001013_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001013.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Heart_and_Vascular_Health_Study_HVH_\",\"DCC_Harmonized_data_set\"]'),(_binary '\í\ì´\nš\êº/BÀ¨','For study MGH Atrial Fibrillation Study','PRIV_FENCE_phs001001_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001001.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"MGH_Atrial_Fibrillation_Study\",\"DCC_Harmonized_data_set\"]'),(_binary '\í\íØš\êº/BÀ¨','For study MGH Atrial Fibrillation Study','PRIV_FENCE_phs001001_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001001.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"MGH_Atrial_Fibrillation_Study\",\"DCC_Harmonized_data_set\"]'),(_binary '\íö‘š\êº/BÀ¨','For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort','PRIV_FENCE_phs000209_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000209.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Multi_Ethnic_Study_of_Atherosclerosis_MESA_Cohort\",\"DCC_Harmonized_data_set\"]'),(_binary '\í÷\Èš\êº/BÀ¨','For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort','PRIV_FENCE_phs000209_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000209.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Multi_Ethnic_Study_of_Atherosclerosis_MESA_Cohort\",\"DCC_Harmonized_data_set\"]'),(_binary '\îÁuš\êº/BÀ¨','For study NHGRI Genome-Wide Association Study of Venous Thromboembolism (GWAS of VTE)','PRIV_FENCE_phs000289_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000289.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHGRI_Genome_Wide_Association_Study_of_Venous_Thromboembolism_GWAS_of_VTE_\",\"DCC_Harmonized_data_set\"]'),(_binary '\î\na¨š\êº/BÀ¨','For study NHLBI Cleveland Family Study (CFS) Candidate Gene Association Resource (CARe)','PRIV_FENCE_phs000284_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000284.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_Cleveland_Family_Study_CFS_Candidate_Gene_Association_Resource_CARe_\",\"DCC_Harmonized_data_set\"]'),(_binary '\îu.š\êº/BÀ¨','For study NHLBI TOPMed: African American Sarcoidosis Genetics Resource','PRIV_FENCE_phs001207_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001207.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_African_American_Sarcoidosis_Genetics_Resource\",\"DCC_Harmonized_data_set\"]'),(_binary '\î\Þš\êº/BÀ¨','For study NHLBI TOPMed: Boston Early-Onset COPD Study in the TOPMed Program','PRIV_FENCE_phs000946_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000946.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Boston_Early_Onset_COPD_Study_in_the_TOPMed_Program\",\"DCC_Harmonized_data_set\"]'),(_binary '\î\\š\êº/BÀ¨','For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)','PRIV_FENCE_phs001412_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001412.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Diabetes_Heart_Study_DHS_African_American_Coronary_Artery_Calcification_AA_CAC_\",\"DCC_Harmonized_data_set\"]'),(_binary '\î7Wš\êº/BÀ¨','For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)','PRIV_FENCE_phs001412_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001412.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Diabetes_Heart_Study_DHS_African_American_Coronary_Artery_Calcification_AA_CAC_\",\"DCC_Harmonized_data_set\"]'),(_binary '\î\"Ý‡š\êº/BÀ¨','For study NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish','PRIV_FENCE_phs000956_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000956.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Genetics_of_Cardiometabolic_Health_in_the_Amish\",\"DCC_Harmonized_data_set\"]'),(_binary '\î&`õš\êº/BÀ¨','For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy','PRIV_FENCE_phs001293_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001293.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_HyperGEN__Genetics_of_Left_Ventricular_LV_Hypertrophy\",\"DCC_Harmonized_data_set\"]'),(_binary '\î\'z\\š\êº/BÀ¨','For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy','PRIV_FENCE_phs001293_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001293.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_HyperGEN__Genetics_of_Left_Ventricular_LV_Hypertrophy\",\"DCC_Harmonized_data_set\"]'),(_binary '\î*\Û\îš\êº/BÀ¨','For study NHLBI TOPMed: Novel Risk Factors for the Development of Atrial Fibrillation in Women','PRIV_FENCE_phs001040_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001040.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Novel_Risk_Factors_for_the_Development_of_Atrial_Fibrillation_in_Women\",\"DCC_Harmonized_data_set\"]'),(_binary '\î/¯\Îš\êº/BÀ¨','For study NHLBI TOPMed: Partners HealthCare Biobank','PRIV_FENCE_phs001024_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001024.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Partners_HealthCare_Biobank\",\"DCC_Harmonized_data_set\"]'),(_binary '\î6ð-š\êº/BÀ¨','For study NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)','PRIV_FENCE_phs001387_c3',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001387.c3\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Rare_Variants_for_Hypertension_in_Taiwan_Chinese_THRV_\",\"DCC_Harmonized_data_set\"]'),(_binary '\î9výš\êº/BÀ¨','For study NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)','PRIV_FENCE_phs001215_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001215.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_San_Antonio_Family_Heart_Study_SAFHS_\",\"DCC_Harmonized_data_set\"]'),(_binary '\î?B#š\êº/BÀ¨','For study NHLBI TOPMed: Study of African Americans, Asthma, Genes and Environment (SAGE) Study','PRIV_FENCE_phs000921_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000921.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_Study_of_African_Americans,_Asthma,_Genes_and_Environment_SAGE_Study\",\"DCC_Harmonized_data_set\"]'),(_binary '\îB­\ìš\êº/BÀ¨','For study NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica','PRIV_FENCE_phs000988_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000988.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_The_Genetic_Epidemiology_of_Asthma_in_Costa_Rica\",\"DCC_Harmonized_data_set\"]'),(_binary '\îG?\Ñš\êº/BÀ¨','For study NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados','PRIV_FENCE_phs001143_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001143.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_The_Genetics_and_Epidemiology_of_Asthma_in_Barbados\",\"DCC_Harmonized_data_set\"]'),(_binary '\îLš\êº/BÀ¨','For study NHLBI TOPMed: The Vanderbilt AF Ablation Registry','PRIV_FENCE_phs000997_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000997.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_The_Vanderbilt_AF_Ablation_Registry\",\"DCC_Harmonized_data_set\"]'),(_binary '\îP–Cš\êº/BÀ¨','For study NHLBI TOPMed: The Vanderbilt Atrial Fibrillation Registry','PRIV_FENCE_phs001032_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs001032.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"NHLBI_TOPMed_The_Vanderbilt_Atrial_Fibrillation_Registry\",\"DCC_Harmonized_data_set\"]'),(_binary '\îUºš\êº/BÀ¨','For study The Jackson Heart Study (JHS)','PRIV_FENCE_phs000286_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000286.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"The_Jackson_Heart_Study_JHS_\",\"DCC_Harmonized_data_set\"]'),(_binary '\îV<š\êº/BÀ¨','For study The Jackson Heart Study (JHS)','PRIV_FENCE_phs000286_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000286.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"The_Jackson_Heart_Study_JHS_\",\"DCC_Harmonized_data_set\"]'),(_binary '\îWW‚š\êº/BÀ¨','For study The Jackson Heart Study (JHS)','PRIV_FENCE_phs000286_c3',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000286.c3\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"The_Jackson_Heart_Study_JHS_\",\"DCC_Harmonized_data_set\"]'),(_binary '\îXkrš\êº/BÀ¨','For study The Jackson Heart Study (JHS)','PRIV_FENCE_phs000286_c4',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000286.c4\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"The_Jackson_Heart_Study_JHS_\",\"DCC_Harmonized_data_set\"]'),(_binary '\îbþš\êº/BÀ¨','For study Women`s Health Initiative','PRIV_FENCE_phs000200_c1',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000200.c1\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Women_s_Health_Initiative\",\"DCC_Harmonized_data_set\"]'),(_binary '\îd\èš\êº/BÀ¨','For study Women`s Health Initiative','PRIV_FENCE_phs000200_c2',_binary '‹W\"\ÉbýHÖ°¿Og\å>û+','{\"categoryFilters\": {\"\\\\_Consents\\\\Short Study Accession with Consent Code\\\\\":[\"phs000200.c2\"]},\"numericFilters\":{},\"requiredFields\":[],\"variantInfoFilters\":[{\"categoryVariantInfoFilters\":{},\"numericVariantInfoFilters\":{}}],\"expectedResultType\": \"COUNT\"}',' [\"Women_s_Health_Initiative\",\"DCC_Harmonized_data_set\"]');
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
INSERT INTO `role` VALUES (_binary '\0-\Ãf°\ØB™ˆ]×—ý','PIC-SURE Top Admin','PIC-SURE Auth Micro App Top admin including Admin and super Admin'),(_binary 'ª­C øGö\Ê\ât(™l ','FENCE_phs001368_c2','FENCE role FENCE_phs001368_c2'),(_binary '¾ˆ\ÆþJ¾xg\ÄÞ§	','FENCE_phs001602_c999','FENCE role FENCE_phs001602_c999'),(_binary '†Gûm\ìOö‹ˆv´Ù³Æž','FENCE_phs001547_c999','FENCE role FENCE_phs001547_c999'),(_binary '	5KÆ¢GÌ¸VD\Ó\å&','FENCE_phs000951_c2','FENCE role FENCE_phs000951_c2'),(_binary 'ŒW \Ø2Mý…V\ã\ßV‰','FENCE_phs001395_c2','FENCE role FENCE_phs001395_c2'),(_binary 'h;¬ujF„½]WE}\Ú','FENCE_phs001661_c999','FENCE role FENCE_phs001661_c999'),(_binary '’}¸)IŸ›„þ`8úZ','FENCE_phs000974_c999','FENCE role FENCE_phs000974_c999'),(_binary '{÷\Ü~\ÂE°±•|]OªB','FENCE_phs001237_c1','FENCE role FENCE_phs001237_c1'),(_binary 'SO&}›C\æƒSº§\ÇTŠ','FENCE_phs001544_c999','FENCE role FENCE_phs001544_c999'),(_binary '\ÏLüû±FÜ›‹	k\ê¡n','FENCE_phs001395_c999','FENCE role FENCE_phs001395_c999'),(_binary '™pöFH•÷\É\ÐÏ‰Ž','FENCE_phs001729_c999','FENCE role FENCE_phs001729_c999'),(_binary '!™5¨°ON[¦\ê¥4ˆÅ—','FENCE_phs001395_c1','FENCE role FENCE_phs001395_c1'),(_binary '!ù\æÁRA.¹\Ç6þ[„t','FENCE_phs001735_c999','FENCE role FENCE_phs001735_c999'),(_binary '%güUó€IJ½\×ÖŽ:\ïß’','FENCE_phs000956_c999','FENCE role FENCE_phs000956_c999'),(_binary '%p(Ÿ%<KñŠ§\â»(K','FENCE_phs001472_c999','FENCE role FENCE_phs001472_c999'),(_binary '%¡-ø\Ê/HË·¼u—\'Š','FENCE_phs001218_c999','FENCE role FENCE_phs001218_c999'),(_binary '\'´¤aRM®¾ü‚¦¿f	³','FENCE_phs001040_c999','FENCE role FENCE_phs001040_c999'),(_binary '\'c—\íJNÛ“Ø†”_\Æ\Î','FENCE_phs001644_c999','FENCE role FENCE_phs001644_c999'),(_binary '\'q—6\ÒÁJÿ\Ý`R´]GQ','FENCE_phs001368_c999','FENCE role FENCE_phs001368_c999'),(_binary '\'ÇŸfT\îB¥”i‹ )«!\ì','FENCE_phs000964_c999','FENCE role FENCE_phs000964_c999'),(_binary '-›«\'AÒ£<\ë;E¬','FENCE_phs001600_c999','FENCE role FENCE_phs001600_c999'),(_binary '.Ž@\ÂD;A˜ŠgÙ± q','FENCE_phs001368_c3','FENCE role FENCE_phs001368_c3'),(_binary '/)B\êLbDÓ‚§—fÁ\ëL','FENCE_phs001604_c999','FENCE role FENCE_phs001604_c999'),(_binary '1Ž]Ý™€C~™»\í\è\ÑÁP','FENCE_phs000974_c1','FENCE role FENCE_phs000974_c1'),(_binary '1\Ü÷[\í8Dc¸\é\Ôn\æ¬©','FENCE_phs001189_c1','FENCE role FENCE_phs001189_c1'),(_binary '2\'L˜0C\n¹2\ÝwZ\ÈD','FENCE_phs001402_c999','FENCE role FENCE_phs001402_c999'),(_binary '5ˆ\íŠA{’\ê\Å;3ºÑ­','FENCE_phs001466_c1','FENCE role FENCE_phs001466_c1'),(_binary 'A(3\Å\å\êDTµ‹ji‡|ü','FENCE_phs001215_c999','FENCE role FENCE_phs001215_c999'),(_binary 'Bq$YŸ\Ç@çŽ„\ÈÈ¤6','FENCE_phs001446_c999','FENCE role FENCE_phs001446_c999'),(_binary 'GC)« N–µ|”·®\"¸5','FENCE_phs000951_c1','FENCE role FENCE_phs000951_c1'),(_binary 'HQ¨TuF›Œõ V\Â\íð\Ì','FENCE_phs001546_c999','FENCE role FENCE_phs001546_c999'),(_binary 'I\Z\Î3µ&L¥¼é°¯Uÿ¥','FENCE_phs001237_c999','FENCE role FENCE_phs001237_c999'),(_binary 'L\0r„IºI·©‡ \ìx\ÅÀ¯','FENCE_phs001211_c1','FENCE role FENCE_phs001211_c1'),(_binary 'N·²ü7›B]µAñA…Ã¥','FENCE_phs001662_c999','FENCE role FENCE_phs001662_c999'),(_binary 'Nô½H…#IÁ·\ÅXs*©','FENCE_phs001730_c999','FENCE role FENCE_phs001730_c999'),(_binary 'Prôt\ï÷F\r´Ex‡´>[','FENCE_phs001468_c999','FENCE role FENCE_phs001468_c999'),(_binary 'Rž3ú—ŒO\åž1…“\Ø\Òú\ë','FENCE_phs001189_c999','FENCE role FENCE_phs001189_c999'),(_binary 'TF}úkrOdœ\\\ß h\Zh®','FENCE_phs000993_c1','FENCE role FENCE_phs000993_c1'),(_binary 'Uˆ\è´‡G‘½~£Ò®W9','FENCE_phs001032_c999','FENCE role FENCE_phs001032_c999'),(_binary 'V[\Ï/B£¶4*‰¯:w','FENCE_phs001606_c999','FENCE role FENCE_phs001606_c999'),(_binary 'X¶x>\ìMt£#:6¼«d\Ç','FENCE_phs001412_c999','FENCE role FENCE_phs001412_c999'),(_binary 'Y«\ç¿<©L\ì]\ë\0Ž¢','FENCE_phs000954_c1','FENCE role FENCE_phs000954_c1'),(_binary 'Yº\ÄNtM)º	w\ÙúP.’','FENCE_phs001434_c999','FENCE role FENCE_phs001434_c999'),(_binary 'Z@_\Ø\ÛM-®?ûuˆ','FENCE_phs000375_c1','FENCE role FENCE_phs000375_c1'),(_binary 'Z©\î/²9O†¬¸š¨ÿ±\ç','FENCE_phs001211_c2','FENCE role FENCE_phs001211_c2'),(_binary '\\^ZkˆG‘h“´€\âK','FENCE_phs000285_c1','FENCE role FENCE_phs000285_c1'),(_binary '^ƒ\ãVKŸ©\ír^*\ÔZ','FENCE_phs001466_c999','FENCE role FENCE_phs001466_c999'),(_binary '^2?A‹\\B»Š²+c\î_\Ñ','FENCE_phs000946_c999','FENCE role FENCE_phs000946_c999'),(_binary '_­‘%Kf´­‘H\\{ð','FENCE_phs001237_c2','FENCE role FENCE_phs001237_c2'),(_binary 'd°£FCû´F~\ß\0€Á','FENCE_phs001435_c999','FENCE role FENCE_phs001435_c999'),(_binary 'nv\Îcô&@›ò¾¼jœZ','FENCE_phs000921_c999','FENCE role FENCE_phs000921_c999'),(_binary 'p~)*D »g$,©L9','FENCE_phs001416_c1','FENCE role FENCE_phs001416_c1'),(_binary 'p96?})Dß—=\Èò\Ðt‘\Ï','FENCE_phs001293_c999','FENCE role FENCE_phs001293_c999'),(_binary 'p\Ò\âðªÁGÔ…ƒðyiW`','FENCE_phs000972_c999','FENCE role FENCE_phs000972_c999'),(_binary 'sˆO\Ô-OF‹ª•\Òy|]•','FENCE_phs000285_c2','FENCE role FENCE_phs000285_c2'),(_binary 's\à^F¤Ix¾Fj°t\ïqs','FENCE_phs001416_c2','FENCE role FENCE_phs001416_c2'),(_binary 't¦ÜµÿLLøô¿\ÚQ€G','FENCE_phs001732_c999','FENCE role FENCE_phs001732_c999'),(_binary '{-K\ê¸\ZE^©Uhˆ©u\ã','FENCE_phs001601_c999','FENCE role FENCE_phs001601_c999'),(_binary '‚K^F©K\ä¬q5$¾ý[','FENCE_phs001211_c999','FENCE role FENCE_phs001211_c999'),(_binary '‚\Òyü_\ëE0©h.¨ÛŒ/','FENCE_phs001612_c2','FENCE role FENCE_phs001612_c2'),(_binary 'ƒûi3&O$•lõ\Ú\ìý»','FENCE_phs001728_c999','FENCE role FENCE_phs001728_c999'),(_binary '†\ßn¡0\ÐGŽ# Ë¶\èR=','FENCE_phs001402_c1','FENCE role FENCE_phs001402_c1'),(_binary '‰Sv\ÙT#J—¼•…D¦','FENCE_phs001062_c999','FENCE role FENCE_phs001062_c999'),(_binary '‰ƒù5\ÕL\ÚC!\×','FENCE_phs000964_c4','FENCE role FENCE_phs000964_c4'),(_binary '”\ÇbD\ÑH+¸$ò~¸&e','FENCE_phs001466_c3','FENCE role FENCE_phs001466_c3'),(_binary '’òŒ/S\àDo–9W˜žl','FENCE_phs001727_c999','FENCE role FENCE_phs001727_c999'),(_binary '”!_C@DN_ ü”h•ñ','FENCE_phs000997_c999','FENCE role FENCE_phs000997_c999'),(_binary '•\ÐTfùMŠ”«\ëÂ´µ\Ö','FENCE_phs001468_c1','FENCE role FENCE_phs001468_c1'),(_binary '–ð\ÈRG½‰yâªž\î{','FENCE_phs001545_c999','FENCE role FENCE_phs001545_c999'),(_binary '—\ÂYºž@HH…\åšÀ‚17g','FENCE_phs001467_c999','FENCE role FENCE_phs001467_c999'),(_binary '™üR\ÍÚ½OOµ„ ü|‡`','FENCE_phs001515_c999','FENCE role FENCE_phs001515_c999'),(_binary 'Ÿ£šl(BEW\ãGUY~','FENCE_phs000974_c2','FENCE role FENCE_phs000974_c2'),(_binary '¡\î\Ü{cB­±\îð\äô‡','FENCE_phs001466_c2','FENCE role FENCE_phs001466_c2'),(_binary '¢§Z¬QMÞ¿Ì‰¦R\Þ','FENCE_phs001726_c999','FENCE role FENCE_phs001726_c999'),(_binary '¢\Øf\Ò\æ»NÆºú–s','FENCE_phs001387_c999','FENCE role FENCE_phs001387_c999'),(_binary '£\âƒa³LN´„Á#±¡O','FENCE_phs001345_c999','FENCE role FENCE_phs001345_c999'),(_binary '¤X¶ÇŸAœ‰K\Æ[ðEH´','FENCE_phs000988_c999','FENCE role FENCE_phs000988_c999'),(_binary '¥Î¯	únL·˜N\ä‚À4ÿ','FENCE_phs001217_c1','FENCE role FENCE_phs001217_c1'),(_binary '§6,@-E­8V O¶G','FENCE_phs001024_c999','FENCE role FENCE_phs001024_c999'),(_binary '¨T\'\Ôk\ëNÁ›¨bu\ê\çðH','FENCE_phs001725_c999','FENCE role FENCE_phs001725_c999'),(_binary '°\Ö\Å]-I„ˆÍ–\î2-»','FENCE_phs001598_c999','FENCE role FENCE_phs001598_c999'),(_binary '´\î\Ëòl\ÅKñ©~\Òw/\r','FENCE_phs000951_c999','FENCE role FENCE_phs000951_c999'),(_binary '¶™ÎšÁL1 ¥fõ%RŽ','FENCE_phs001143_c999','FENCE role FENCE_phs001143_c999'),(_binary '¶T½D\'GU•Ap;5qm2','FENCE_phs000920_c2','FENCE role FENCE_phs000920_c2'),(_binary '¶²\'ô\ÍE—“1§š\Ü%\ï','FENCE_phs001368_c4','FENCE role FENCE_phs001368_c4'),(_binary '¸½B‡3\çE‡ û	‚ö','FENCE_phs001603_c999','FENCE role FENCE_phs001603_c999'),(_binary '¹Ç‘\ÒDh¡(<òõˆ\é','FENCE_phs001368_c1','FENCE role FENCE_phs001368_c1'),(_binary 'º®uX¥A©xÁYU\ZC','FENCE_phs001607_c999','FENCE role FENCE_phs001607_c999'),(_binary '¾xyZCª–:»\Ï1r','FENCE_phs000810_c2','FENCE role FENCE_phs000810_c2'),(_binary '¿	6?GþF³¥“\Çy´ô‰K','FENCE_phs001218_c2','FENCE role FENCE_phs001218_c2'),(_binary 'À¸5r•ùDÛ¤Áv\Í\Õ\ï','FENCE_phs000993_c999','FENCE role FENCE_phs000993_c999'),(_binary 'Á\Üz\nC¬L!‹\î~\Õ','FENCE_phs001207_c999','FENCE role FENCE_phs001207_c999'),(_binary 'Ãš›®A\ÈGv¿h¸\î²\Öô','FENCE_phs001605_c999','FENCE role FENCE_phs001605_c999'),(_binary '\Ä\ä‚\ÔXþKÝ =o´Z\Ô\Ô','FENCE_phs001542_c999','FENCE role FENCE_phs001542_c999'),(_binary '\Ér6;ŽBÝ­ ­u­3û','FENCE_phs001062_c1','FENCE role FENCE_phs001062_c1'),(_binary '\É\ì_x\"@@nt€\æ¼ \Õ','FENCE_phs001608_c999','FENCE role FENCE_phs001608_c999'),(_binary 'ËŒ40F@F…\áC7\Üø=:','FENCE_phs000964_c3','FENCE role FENCE_phs000964_c3'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/','FENCE_topmed','FENCE role FENCE_topmed'),(_binary '\Ï121THƒ\È\r%\áM','FENCE_phs000972_c1','FENCE role FENCE_phs000972_c1'),(_binary '\ÏAÁôLœCG¤¯5\ä\Ëò\ï-','FENCE_phs001682_c999','FENCE role FENCE_phs001682_c999'),(_binary '\ÖZEt\ZdIÂ®„\ÌA3^M;','FENCE_phs001217_c999','FENCE role FENCE_phs001217_c999'),(_binary '\Ùp\ÉWø@°ª\ëo\ß\ß\ä†','FENCE_phs000920_c999','FENCE role FENCE_phs000920_c999'),(_binary '\ß$\Ð\È\âO¼¬š\nó8®?','FENCE_phs001612_c1','FENCE role FENCE_phs001612_c1'),(_binary 'ß«ù1\0cO\0­„Å±P€','FENCE_phs001515_c1','FENCE role FENCE_phs001515_c1'),(_binary '\à‡!\×KO»›…\ãBÏ­\ë','FENCE_phs001416_c999','FENCE role FENCE_phs001416_c999'),(_binary '\à\å\Å\ÐGòBÂ¶\×\ÕL\åj‚\Ó','FENCE_phs000964_c1','FENCE role FENCE_phs000964_c1'),(_binary '\â*ónc1OG½\â\Ð\ä¼\î\r•','FENCE_phs001359_c1','FENCE role FENCE_phs001359_c1'),(_binary '\âGJ@ZhJ²—ß¦µ7?','FENCE_phs000964_c2','FENCE role FENCE_phs000964_c2'),(_binary '\ä™ó\à‹}HÌ¬K\Ú7\\¯','FENCE_phs001514_c999','FENCE role FENCE_phs001514_c999'),(_binary '\å\×Z@cJx™‡u\â\Ì\ê','FENCE_phs001062_c2','FENCE role FENCE_phs001062_c2'),(_binary '\é|V¨ALr Y\Åj±³e','FENCE_phs001345_c1','FENCE role FENCE_phs001345_c1'),(_binary '\ë#ÿ\Í\r¨Oýž:\ÅÁd\"^','FENCE_phs001612_c999','FENCE role FENCE_phs001612_c999'),(_binary '\ëÁ\ï‘Î†F8€’ú!§6\æ','FENCE_phs001543_c999','FENCE role FENCE_phs001543_c999'),(_binary '\í],š\êº/BÀ¨','FENCE_phs000280_c1','For study Atherosclerosis Risk in Communities (ARIC) Cohort'),(_binary '\í‚\Æš\êº/BÀ¨','FENCE_phs000280_c2','For study Atherosclerosis Risk in Communities (ARIC) Cohort'),(_binary '\íŒš\êº/BÀ¨','FENCE_phs000287_c1','For study Cardiovascular Health Study (CHS) Cohort'),(_binary '\í4mš\êº/BÀ¨','FENCE_phs000287_c2','For study Cardiovascular Health Study (CHS) Cohort'),(_binary '\íŽA{š\êº/BÀ¨','FENCE_phs000287_c3','For study Cardiovascular Health Study (CHS) Cohort'),(_binary '\íHš\êº/BÀ¨','FENCE_phs000287_c4','For study Cardiovascular Health Study (CHS) Cohort'),(_binary '\í™w‡š\êº/BÀ¨','FENCE_phs000007_c1','For study Framingham Cohort'),(_binary 'íš‚š\êº/BÀ¨','FENCE_phs000007_c2','For study Framingham Cohort'),(_binary 'í¨§bš\êº/BÀ¨','FENCE_phs001074_c2','For study GeneSTAR NextGen Functional Genomics of Platelet Aggregation'),(_binary '\í±\Ätš\êº/BÀ¨','FENCE_phs001180_c2','For study Genes-Environments and Admixture in Latino Asthmatics (GALA II) Study'),(_binary 'íµžzš\êº/BÀ¨','FENCE_phs001238_c1','For study Genetic Epidemiology Network of Arteriopathy (GENOA)'),(_binary 'í¾’Bš\êº/BÀ¨','FENCE_phs000784_c1','For study Genetic Epidemiology Network of Salt Sensitivity (GenSalt)'),(_binary '\íÇ¨kš\êº/BÀ¨','FENCE_phs000179_c1','For study Genetic Epidemiology of COPD (COPDGene)'),(_binary '\íÈµcš\êº/BÀ¨','FENCE_phs000179_c2','For study Genetic Epidemiology of COPD (COPDGene)'),(_binary '\í\Ð\Ý*š\êº/BÀ¨','FENCE_phs000741_c1','For study Genetics of Lipid Lowering Drugs and Diet Network (GOLDN) Lipidomics Study'),(_binary '\í\Þðš\êº/BÀ¨','FENCE_phs000914_c1','For study Genome-wide Association Study of Adiposity in Samoans'),(_binary '\í\âñ<š\êº/BÀ¨','FENCE_phs001013_c1','For study Heart and Vascular Health Study (HVH)'),(_binary '\í\ä:wš\êº/BÀ¨','FENCE_phs001013_c2','For study Heart and Vascular Health Study (HVH)'),(_binary '\í\ì5š\êº/BÀ¨','FENCE_phs001001_c1','For study MGH Atrial Fibrillation Study'),(_binary '\í\í•#š\êº/BÀ¨','FENCE_phs001001_c2','For study MGH Atrial Fibrillation Study'),(_binary '\íö[]š\êº/BÀ¨','FENCE_phs000209_c1','For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort'),(_binary '\í÷‘\0š\êº/BÀ¨','FENCE_phs000209_c2','For study Multi-Ethnic Study of Atherosclerosis (MESA) Cohort'),(_binary '\îŒ†š\êº/BÀ¨','FENCE_phs000289_c1','For study NHGRI Genome-Wide Association Study of Venous Thromboembolism (GWAS of VTE)'),(_binary '\î\n,\âš\êº/BÀ¨','FENCE_phs000284_c1','For study NHLBI Cleveland Family Study (CFS) Candidate Gene Association Resource (CARe)'),(_binary '\î?0š\êº/BÀ¨','FENCE_phs001207_c1','For study NHLBI TOPMed: African American Sarcoidosis Genetics Resource'),(_binary '\îK:š\êº/BÀ¨','FENCE_phs000946_c1','For study NHLBI TOPMed: Boston Early-Onset COPD Study in the TOPMed Program'),(_binary '\î\è\ëš\êº/BÀ¨','FENCE_phs001412_c1','For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)'),(_binary '\î\0°š\êº/BÀ¨','FENCE_phs001412_c2','For study NHLBI TOPMed: Diabetes Heart Study (DHS) African American Coronary Artery Calcification (AA CAC)'),(_binary '\î\" \îš\êº/BÀ¨','FENCE_phs000956_c2','For study NHLBI TOPMed: Genetics of Cardiometabolic Health in the Amish'),(_binary '\î&(Bš\êº/BÀ¨','FENCE_phs001293_c1','For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy'),(_binary '\î\'A\Óš\êº/BÀ¨','FENCE_phs001293_c2','For study NHLBI TOPMed: HyperGEN - Genetics of Left Ventricular (LV) Hypertrophy'),(_binary '\î*¦nš\êº/BÀ¨','FENCE_phs001040_c1','For study NHLBI TOPMed: Novel Risk Factors for the Development of Atrial Fibrillation in Women'),(_binary '\î/q]š\êº/BÀ¨','FENCE_phs001024_c1','For study NHLBI TOPMed: Partners HealthCare Biobank'),(_binary '\î6¸þš\êº/BÀ¨','FENCE_phs001387_c3','For study NHLBI TOPMed: Rare Variants for Hypertension in Taiwan Chinese (THRV)'),(_binary '\î9?\"š\êº/BÀ¨','FENCE_phs001215_c1','For study NHLBI TOPMed: San Antonio Family Heart Study (SAFHS)'),(_binary '\î?Bš\êº/BÀ¨','FENCE_phs000921_c2','For study NHLBI TOPMed: Study of African Americans, Asthma, Genes and Environment (SAGE) Study'),(_binary '\îBy¸š\êº/BÀ¨','FENCE_phs000988_c1','For study NHLBI TOPMed: The Genetic Epidemiology of Asthma in Costa Rica'),(_binary '\îG\n·š\êº/BÀ¨','FENCE_phs001143_c1','For study NHLBI TOPMed: The Genetics and Epidemiology of Asthma in Barbados'),(_binary '\îK\Îš\êº/BÀ¨','FENCE_phs000997_c1','For study NHLBI TOPMed: The Vanderbilt AF Ablation Registry'),(_binary '\îPZVš\êº/BÀ¨','FENCE_phs001032_c1','For study NHLBI TOPMed: The Vanderbilt Atrial Fibrillation Registry'),(_binary '\îT\å²š\êº/BÀ¨','FENCE_phs000286_c1','For study The Jackson Heart Study (JHS)'),(_binary '\îVIš\êº/BÀ¨','FENCE_phs000286_c2','For study The Jackson Heart Study (JHS)'),(_binary '\îW$wš\êº/BÀ¨','FENCE_phs000286_c3','For study The Jackson Heart Study (JHS)'),(_binary '\îX4\Êš\êº/BÀ¨','FENCE_phs000286_c4','For study The Jackson Heart Study (JHS)'),(_binary '\îb\ÆAš\êº/BÀ¨','FENCE_phs000200_c1','For study Women`s Health Initiative'),(_binary '\îcØ‡š\êº/BÀ¨','FENCE_phs000200_c2','For study Women`s Health Initiative'),(_binary '÷oÀ\ãf†C‚•;\0htf.','FENCE_phs000954_c999','FENCE role FENCE_phs000954_c999'),(_binary 'ûv²‰VAY–K/¿±5ôÀ','FENCE_phs001359_c999','FENCE role FENCE_phs001359_c999'),(_binary 'ýúôd\rL?™/ $½¹ù','FENCE_phs001624_c999','FENCE role FENCE_phs001624_c999'),(_binary 'ý¹KÒ¸\àÆ£”\r ?','FENCE_phs000993_c2','FENCE role FENCE_phs000993_c2'),(_binary 'ÿx“\íO¾C\åó\ã\êv','FENCE_phs000810_c1','FENCE role FENCE_phs000810_c1');
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
INSERT INTO `role_privilege` VALUES (_binary '\0-\Ãf°\ØB™ˆ]×—ý',_binary 'pD\Zö[B_†\Îs¡¿D'),(_binary '\0-\Ãf°\ØB™ˆ]×—ý',_binary '­!.	oALº®	A]«'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary 'íª¸š\êº/BÀ¨'),(_binary '\í],š\êº/BÀ¨',_binary 'íª¸š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\íƒ™š\êº/BÀ¨'),(_binary '\í‚\Æš\êº/BÀ¨',_binary '\íƒ™š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\íŒ7©š\êº/BÀ¨'),(_binary '\íŒš\êº/BÀ¨',_binary '\íŒ7©š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\íh|š\êº/BÀ¨'),(_binary '\í4mš\êº/BÀ¨',_binary '\íh|š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\íŽyš\êº/BÀ¨'),(_binary '\íŽA{š\êº/BÀ¨',_binary '\íŽyš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í\Zš\êº/BÀ¨'),(_binary '\íHš\êº/BÀ¨',_binary '\í\Zš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary 'í™¬\ïš\êº/BÀ¨'),(_binary '\í™w‡š\êº/BÀ¨',_binary 'í™¬\ïš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary 'íš·ñš\êº/BÀ¨'),(_binary 'íš‚š\êº/BÀ¨',_binary 'íš·ñš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í¨\ÛAš\êº/BÀ¨'),(_binary 'í¨§bš\êº/BÀ¨',_binary '\í¨\ÛAš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í²š\êº/BÀ¨'),(_binary '\í±\Ätš\êº/BÀ¨',_binary '\í²š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\íµ\Õ\Üš\êº/BÀ¨'),(_binary 'íµžzš\êº/BÀ¨',_binary '\íµ\Õ\Üš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í¾\Õwš\êº/BÀ¨'),(_binary 'í¾’Bš\êº/BÀ¨',_binary '\í¾\Õwš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í\Ç\Ýpš\êº/BÀ¨'),(_binary '\íÇ¨kš\êº/BÀ¨',_binary '\í\Ç\Ýpš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í\Èð~š\êº/BÀ¨'),(_binary '\íÈµcš\êº/BÀ¨',_binary '\í\Èð~š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í\Ñ\Ëš\êº/BÀ¨'),(_binary '\í\Ð\Ý*š\êº/BÀ¨',_binary '\í\Ñ\Ëš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\íÞ·š\êº/BÀ¨'),(_binary '\í\Þðš\êº/BÀ¨',_binary '\íÞ·š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í\ã\'µš\êº/BÀ¨'),(_binary '\í\âñ<š\êº/BÀ¨',_binary '\í\ã\'µš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í\äs½š\êº/BÀ¨'),(_binary '\í\ä:wš\êº/BÀ¨',_binary '\í\äs½š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í\ì´\nš\êº/BÀ¨'),(_binary '\í\ì5š\êº/BÀ¨',_binary '\í\ì´\nš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í\íØš\êº/BÀ¨'),(_binary '\í\í•#š\êº/BÀ¨',_binary '\í\íØš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\íö‘š\êº/BÀ¨'),(_binary '\íö[]š\êº/BÀ¨',_binary '\íö‘š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\í÷\Èš\êº/BÀ¨'),(_binary '\í÷‘\0š\êº/BÀ¨',_binary '\í÷\Èš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îÁuš\êº/BÀ¨'),(_binary '\îŒ†š\êº/BÀ¨',_binary '\îÁuš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î\na¨š\êº/BÀ¨'),(_binary '\î\n,\âš\êº/BÀ¨',_binary '\î\na¨š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îu.š\êº/BÀ¨'),(_binary '\î?0š\êº/BÀ¨',_binary '\îu.š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î\Þš\êº/BÀ¨'),(_binary '\îK:š\êº/BÀ¨',_binary '\î\Þš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î\\š\êº/BÀ¨'),(_binary '\î\è\ëš\êº/BÀ¨',_binary '\î\\š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î7Wš\êº/BÀ¨'),(_binary '\î\0°š\êº/BÀ¨',_binary '\î7Wš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î\"Ý‡š\êº/BÀ¨'),(_binary '\î\" \îš\êº/BÀ¨',_binary '\î\"Ý‡š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î&`õš\êº/BÀ¨'),(_binary '\î&(Bš\êº/BÀ¨',_binary '\î&`õš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î\'z\\š\êº/BÀ¨'),(_binary '\î\'A\Óš\êº/BÀ¨',_binary '\î\'z\\š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î*\Û\îš\êº/BÀ¨'),(_binary '\î*¦nš\êº/BÀ¨',_binary '\î*\Û\îš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î/¯\Îš\êº/BÀ¨'),(_binary '\î/q]š\êº/BÀ¨',_binary '\î/¯\Îš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î6ð-š\êº/BÀ¨'),(_binary '\î6¸þš\êº/BÀ¨',_binary '\î6ð-š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î9výš\êº/BÀ¨'),(_binary '\î9?\"š\êº/BÀ¨',_binary '\î9výš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\î?B#š\êº/BÀ¨'),(_binary '\î?Bš\êº/BÀ¨',_binary '\î?B#š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îB­\ìš\êº/BÀ¨'),(_binary '\îBy¸š\êº/BÀ¨',_binary '\îB­\ìš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îG?\Ñš\êº/BÀ¨'),(_binary '\îG\n·š\êº/BÀ¨',_binary '\îG?\Ñš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îLš\êº/BÀ¨'),(_binary '\îK\Îš\êº/BÀ¨',_binary '\îLš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îP–Cš\êº/BÀ¨'),(_binary '\îPZVš\êº/BÀ¨',_binary '\îP–Cš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îUºš\êº/BÀ¨'),(_binary '\îT\å²š\êº/BÀ¨',_binary '\îUºš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îV<š\êº/BÀ¨'),(_binary '\îVIš\êº/BÀ¨',_binary '\îV<š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îWW‚š\êº/BÀ¨'),(_binary '\îW$wš\êº/BÀ¨',_binary '\îWW‚š\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îXkrš\êº/BÀ¨'),(_binary '\îX4\Êš\êº/BÀ¨',_binary '\îXkrš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îbþš\êº/BÀ¨'),(_binary '\îb\ÆAš\êº/BÀ¨',_binary '\îbþš\êº/BÀ¨'),(_binary '\Ë\çMT^Aÿ·Ê¹6§­\r/',_binary '\îd\èš\êº/BÀ¨'),(_binary '\îcØ‡š\êº/BÀ¨',_binary '\îd\èš\êº/BÀ¨');
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
  `auth0_metadata` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `general_metadata` varchar(15000) COLLATE utf8_bin DEFAULT NULL,
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

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-12-11 20:22:10
