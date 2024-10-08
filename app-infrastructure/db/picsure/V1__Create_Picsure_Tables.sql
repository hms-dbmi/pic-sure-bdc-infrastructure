USE
`picsure2`;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user`
(
    `uuid`    binary(16) NOT NULL,
    `roles`   varchar(255) COLLATE utf8_bin DEFAULT NULL,
    `subject` varchar(255) COLLATE utf8_bin DEFAULT NULL,
    `userId`  varchar(255) COLLATE utf8_bin DEFAULT NULL,
    PRIMARY KEY (`uuid`),
    UNIQUE KEY `subject_UNIQUE` (`subject`),
    UNIQUE KEY `userId_UNIQUE` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK
TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK
TABLES;
--
-- Table structure for table `resource`
--

DROP TABLE IF EXISTS `resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource`
(
    `uuid`           binary(16) NOT NULL,
    `targetURL`      varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `resourceRSPath` varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `description`    varchar(8192) COLLATE utf8_bin DEFAULT NULL,
    `name`           varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `token`          varchar(8192) COLLATE utf8_bin DEFAULT NULL,
    `hidden`         BOOL                           default NULL,
    `metadata`       TEXT                           default NULL,
    PRIMARY KEY (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `query`
--

DROP TABLE IF EXISTS `query`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `query`
(
    `uuid`             binary(16) NOT NULL,
    `query`            longblob,
    `readyTime`        date                          DEFAULT NULL,
    `resourceResultId` varchar(255) COLLATE utf8_bin DEFAULT NULL,
    `startTime`        date                          DEFAULT NULL,
    `status`           int(11) DEFAULT NULL,
    `resourceId`       binary(16) DEFAULT NULL,
    `metadata`         blob,
    PRIMARY KEY (`uuid`),
    KEY                `FKhgiwd8kmi6pjw16txfhyqk2w0` (`resourceId`),
    CONSTRAINT `FKhgiwd8kmi6pjw16txfhyqk2w0` FOREIGN KEY (`resourceId`) REFERENCES `resource` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `query`
--

LOCK
TABLES `query` WRITE;
/*!40000 ALTER TABLE `query` DISABLE KEYS */;
/*!40000 ALTER TABLE `query` ENABLE KEYS */;
UNLOCK
TABLES;

--
-- Table structure for table `named_dataset`
--

DROP TABLE IF EXISTS `named_dataset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `named_dataset`
(
    `uuid`     binary(16) NOT NULL,
    `queryId`  binary(16) NOT NULL,
    `user`     varchar(255) COLLATE utf8_bin DEFAULT NULL,
    `name`     varchar(255) COLLATE utf8_bin DEFAULT NULL,
    `archived` bit(1) NOT NULL               DEFAULT FALSE,
    `metadata` TEXT,
    PRIMARY KEY (`uuid`),
    CONSTRAINT `foreign_queryId` FOREIGN KEY (`queryId`) REFERENCES `query` (`uuid`),
    CONSTRAINT `unique_queryId_user` UNIQUE (`queryId`, `user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
