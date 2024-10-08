USE
`auth2`;
--
-- Table structure for table `application`
--

DROP TABLE IF EXISTS `application`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application`
(
    `uuid`        binary(16) NOT NULL,
    `description` varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `enable`      bit(1) NOT NULL                DEFAULT b'1',
    `name`        varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `token`       varchar(2000) COLLATE utf8_bin DEFAULT NULL,
    `url`         varchar(500) COLLATE utf8_bin  DEFAULT NULL,
    PRIMARY KEY (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
--
-- Table structure for table `privilege`
--

DROP TABLE IF EXISTS `privilege`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `privilege`
(
    `uuid`           binary(16) NOT NULL,
    `description`    varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `name`           varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `application_id` binary(16) DEFAULT NULL,
    `queryTemplate`  varchar(8192) COLLATE utf8_bin DEFAULT NULL,
    `queryScope`     varchar(512) COLLATE utf8_bin  DEFAULT NULL,
    PRIMARY KEY (`uuid`),
    UNIQUE KEY `UK_h7iwbdg4ev8mgvmij76881tx8` (`name`),
    KEY              `FK61h3jewffk70b5ni4tsi5rhoy` (`application_id`),
    CONSTRAINT `FK61h3jewffk70b5ni4tsi5rhoy` FOREIGN KEY (`application_id`) REFERENCES `application` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `access_rule`
--

DROP TABLE IF EXISTS `access_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_rule`
(
    `uuid`                     binary(16) NOT NULL,
    `name`                     varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `description`              varchar(2000) COLLATE utf8_bin DEFAULT NULL,
    `rule`                     varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `type`                     int(11) DEFAULT NULL,
    `value`                    varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `checkMapKeyOnly`          bit(1) NOT NULL,
    `checkMapNode`             bit(1) NOT NULL,
    `subAccessRuleParent_uuid` binary(16) DEFAULT NULL,
    `isGateAnyRelation`        bit(1) NOT NULL,
    `isEvaluateOnlyByGates`    bit(1) NOT NULL,
    PRIMARY KEY (`uuid`),
    KEY                        `FK8rovvx363ui99ce21sksmg6uy` (`subAccessRuleParent_uuid`),
    CONSTRAINT `FK8rovvx363ui99ce21sksmg6uy` FOREIGN KEY (`subAccessRuleParent_uuid`) REFERENCES `access_rule` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `accessRule_gate`
--

DROP TABLE IF EXISTS `accessRule_gate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accessRule_gate`
(
    `accessRule_id` binary(16) NOT NULL,
    `gate_id`       binary(16) NOT NULL,
    PRIMARY KEY (`accessRule_id`, `gate_id`),
    KEY             `FK6re4kcq9tyl45jv9yg584doem` (`gate_id`),
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
CREATE TABLE `accessRule_privilege`
(
    `privilege_id`  binary(16) NOT NULL,
    `accessRule_id` binary(16) NOT NULL,
    PRIMARY KEY (`privilege_id`, `accessRule_id`),
    KEY             `FK89rf30kbf9d246jty2dd7qk99` (`accessRule_id`),
    CONSTRAINT `FK7x47w81gpua380qd7lp9x94l1` FOREIGN KEY (`privilege_id`) REFERENCES `privilege` (`uuid`),
    CONSTRAINT `FK89rf30kbf9d246jty2dd7qk99` FOREIGN KEY (`accessRule_id`) REFERENCES `access_rule` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `accessRule_subRule`
--
CREATE TABLE `accessRule_subRule`
(
    `accessRule_id` binary(16) NOT NULL,
    `subRule_id`    binary(16) NOT NULL,
    PRIMARY KEY (`accessRule_id`, `subRule_id`),
    KEY (`subRule_id`),
    CONSTRAINT FOREIGN KEY (`subRule_id`) REFERENCES `access_rule` (`uuid`),
    CONSTRAINT FOREIGN KEY (`accessRule_id`) REFERENCES `access_rule` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


--
-- Table structure for table `connection`
--

DROP TABLE IF EXISTS `connection`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connection`
(
    `uuid`           binary(16) NOT NULL,
    `label`          varchar(255) COLLATE utf8_bin  NOT NULL,
    `id`             varchar(255) COLLATE utf8_bin  NOT NULL,
    `subprefix`      varchar(255) COLLATE utf8_bin  NOT NULL,
    `requiredFields` varchar(9000) COLLATE utf8_bin NOT NULL,
    PRIMARY KEY (`uuid`),
    UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role`
(
    `uuid`        binary(16) NOT NULL,
    `name`        varchar(255) COLLATE utf8_bin DEFAULT NULL,
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
CREATE TABLE `role_privilege`
(
    `role_id`      binary(16) NOT NULL,
    `privilege_id` binary(16) NOT NULL,
    PRIMARY KEY (`role_id`, `privilege_id`),
    KEY            `FKdkwbrwb5r8h74m1v7dqmhp99c` (`privilege_id`),
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
CREATE TABLE `termsOfService`
(
    `uuid`        binary(16) NOT NULL,
    `dateUpdated` timestamp NOT NULL             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `content`     varchar(9000) COLLATE utf8_bin DEFAULT NULL,
    PRIMARY KEY (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user`
(
    `uuid`              binary(16) NOT NULL,
    `auth0_metadata`    longtext COLLATE utf8_bin      DEFAULT NULL,
    `general_metadata`  longtext COLLATE utf8_bin      DEFAULT NULL,
    `acceptedTOS`       datetime                       DEFAULT NULL,
    `connectionId`      binary(16) DEFAULT NULL,
    `email`             varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `matched`           bit(1) NOT NULL                DEFAULT b'0',
    `subject`           varchar(255) COLLATE utf8_bin  DEFAULT NULL,
    `is_active`         bit(1) NOT NULL                DEFAULT b'1',
    `long_term_token`   varchar(4000) COLLATE utf8_bin DEFAULT NULL,
    `isGateAnyRelation` bit(1) NOT NULL                DEFAULT b'1',
    PRIMARY KEY (`uuid`),
    UNIQUE KEY `UK_r8xpakluitn685ua7pt8xjy9r` (`subject`),
    KEY                 `FKn8bku0vydfcnuwbqwgnbgg8ry` (`connectionId`),
    CONSTRAINT `FKn8bku0vydfcnuwbqwgnbgg8ry` FOREIGN KEY (`connectionId`) REFERENCES `connection` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `userMetadataMapping`
--

DROP TABLE IF EXISTS `userMetadataMapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userMetadataMapping`
(
    `uuid`                    binary(16) NOT NULL,
    `auth0MetadataJsonPath`   varchar(255) COLLATE utf8_bin DEFAULT NULL,
    `connectionId`            binary(16) DEFAULT NULL,
    `generalMetadataJsonPath` varchar(255) COLLATE utf8_bin DEFAULT NULL,
    PRIMARY KEY (`uuid`),
    KEY                       `FKayr8vrvvwpgsdhxdyryt6k590` (`connectionId`),
    CONSTRAINT `FKayr8vrvvwpgsdhxdyryt6k590` FOREIGN KEY (`connectionId`) REFERENCES `connection` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_role`
--

DROP TABLE IF EXISTS `user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_role`
(
    `user_id` binary(16) NOT NULL,
    `role_id` binary(16) NOT NULL,
    PRIMARY KEY (`user_id`, `role_id`),
    KEY       `FKa68196081fvovjhkek5m97n3y` (`role_id`),
    CONSTRAINT `FK859n2jvi8ivhui0rl0esws6o` FOREIGN KEY (`user_id`) REFERENCES `user` (`uuid`),
    CONSTRAINT `FKa68196081fvovjhkek5m97n3y` FOREIGN KEY (`role_id`) REFERENCES `role` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;