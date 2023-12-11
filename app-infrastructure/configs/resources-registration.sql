/**
This script needs to run if an application is using a persistant application RDS
The resources are not stored in a dynamic fashion so they need to be upserted with each deployment

**/

USE `picsure`;
-- Upsert to resources tables to handle stack hardcodings.
-- We have multiple stacks so we CANNOT use the same UUID for both if they are both reliant on the same RDS
-- if we ever want to make this compatiable with other interfaces we must make resource configuration more abstract and dynamic. - TD
--
-- ___target_stack___ will be replaced by the appropriate target stack via the TARGET_STACK environment variable
-- See edu.harvard.dbmi.avillach.data.entity.Resource for details
/*!40000 ALTER TABLE `resource` DISABLE KEYS */;
${include_auth_hpds ? "INSERT INTO `resource` VALUES (0x02E23F52F3544E8B992CD37C8B9BA140,NULL,'http://auth-hpds.___target_stack___:8080/PIC-SURE/','Authorized Access HPDS resource','auth-hpds',NULL, NULL, NULL) ON DUPLICATE KEY UPDATE `resourceRSPath` = VALUES(`resourceRSPath`);" : ""}
INSERT INTO `resource` VALUES (0x36363664623161342d386538652d3131, NULL, 'http://dictionary.___target_stack___:8080/dictionary/pic-sure', 'Dictionary', 'dictionary', NULL, NULL, NULL) ON DUPLICATE KEY UPDATE `resourceRSPath` = VALUES(`resourceRSPath`);
/*!40000 ALTER TABLE `resource` ENABLE KEYS */;