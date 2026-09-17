/* Remove retired authorization generated before pic-sure 968ba0712.
 * Shared migration: identify local binary UUIDs from generator signatures.
 * Run only after the v2 application is retired and all auth writers are stopped.
 * The operator must approve a restore-tested backup and the maintenance window.
 * The global InnoDB foreign-key catalog is cross-checked. If the account cannot read it the
 * migration aborts before any change rather than proceeding blind.
 * Inspecting triggers requires a direct schema-level or table-level TRIGGER grant, or a global
 * TRIGGER grant while partial_revokes is OFF. Role-only grants are conservatively rejected.
 * No grants are changed and no auth columns are altered. Retained privileges may lose their
 * generated AR_INFO_COLUMN_LISTING rule; the run stops if that would leave any with no rules.
 * CHECK constraints must be enforced. Flyway 10.8.1 / MySQL 8.0.45 are the tested versions.
 */
USE auth;
CREATE TEMPORARY TABLE tmp_cleanup_assert (
 check_name VARCHAR(128) NOT NULL PRIMARY KEY,
 passed TINYINT NOT NULL,
 CONSTRAINT legacy_v2_preflight_must_pass CHECK (passed = 1)
) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'tested_mysql_version', IF((VERSION() = '8.0.45'),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'sql_literal_mode', IF((FIND_IN_SET('NO_BACKSLASH_ESCAPES',@@sql_mode)=0),1,0);

CREATE TEMPORARY TABLE tmp_cleanup_required_table (table_name VARCHAR(64) PRIMARY KEY) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_required_table VALUES ('accessRule_gate'),('accessRule_privilege'),('accessRule_subRule'),('access_rule'),('application'),('connection'),('privilege'),('role'),('role_privilege'),('user'),('user_role');

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'required_innodb_tables', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_required_table e LEFT JOIN information_schema.tables t ON CAST(t.table_schema AS BINARY)=CAST(DATABASE() AS BINARY) AND CAST(t.table_name AS BINARY)=CAST(e.table_name AS BINARY) WHERE t.table_name IS NULL OR t.engine <> 'InnoDB' OR t.table_type <> 'BASE TABLE')),1,0);

CREATE TEMPORARY TABLE tmp_cleanup_required_column (table_name VARCHAR(64),column_name VARCHAR(64),column_type VARCHAR(255),PRIMARY KEY(table_name,column_name)) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_required_column VALUES
('accessRule_gate','accessRule_id','binary(16)'),
('accessRule_gate','gate_id','binary(16)'),
('accessRule_privilege','accessRule_id','binary(16)'),
('accessRule_privilege','privilege_id','binary(16)'),
('accessRule_subRule','accessRule_id','binary(16)'),
('accessRule_subRule','subRule_id','binary(16)'),
('access_rule','checkMapKeyOnly','bit(1)'),
('access_rule','checkMapNode','bit(1)'),
('access_rule','description','varchar(2000)'),
('access_rule','isEvaluateOnlyByGates','bit(1)'),
('access_rule','isGateAnyRelation','bit(1)'),
('access_rule','name','varchar(255)'),
('access_rule','rule','varchar(255)'),
('access_rule','subAccessRuleParent_uuid','binary(16)'),
('access_rule','type','int'),
('access_rule','uuid','binary(16)'),
('access_rule','value','varchar(255)'),
('application','name','varchar(255)'),
('application','uuid','binary(16)'),
('connection','id','varchar(255)'),
('connection','label','varchar(255)'),
('connection','subprefix','varchar(255)'),
('connection','uuid','binary(16)'),
('privilege','application_id','binary(16)'),
('privilege','description','varchar(255)'),
('privilege','name','varchar(255)'),
('privilege','queryScope','varchar(512)'),
('privilege','queryTemplate','varchar(8192)'),
('privilege','uuid','binary(16)'),
('role','description','varchar(255)'),
('role','name','varchar(255)'),
('role','uuid','binary(16)'),
('role_privilege','privilege_id','binary(16)'),
('role_privilege','role_id','binary(16)'),
('user','connectionId','binary(16)'),
('user','uuid','binary(16)'),
('user_role','role_id','binary(16)'),
('user_role','user_id','binary(16)');

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'required_column_types', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_required_column e LEFT JOIN information_schema.columns c ON CAST(c.table_schema AS BINARY)=CAST(DATABASE() AS BINARY) AND CAST(c.table_name AS BINARY)=CAST(e.table_name AS BINARY) AND CAST(c.column_name AS BINARY)=CAST(e.column_name AS BINARY) WHERE c.column_name IS NULL OR c.column_type <> e.column_type)),1,0);

CREATE TEMPORARY TABLE tmp_cleanup_required_fk (child_table VARCHAR(64),child_column VARCHAR(64),parent_table VARCHAR(64),parent_column VARCHAR(64),PRIMARY KEY(child_table,child_column)) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_required_fk VALUES
('accessRule_gate','gate_id','access_rule','uuid'),
('accessRule_gate','accessRule_id','access_rule','uuid'),
('accessRule_privilege','privilege_id','privilege','uuid'),
('accessRule_privilege','accessRule_id','access_rule','uuid'),
('accessRule_subRule','subRule_id','access_rule','uuid'),
('accessRule_subRule','accessRule_id','access_rule','uuid'),
('access_rule','subAccessRuleParent_uuid','access_rule','uuid'),
('privilege','application_id','application','uuid'),
('role_privilege','privilege_id','privilege','uuid'),
('role_privilege','role_id','role','uuid'),
('user_role','user_id','user','uuid'),
('user_role','role_id','role','uuid');

CREATE TEMPORARY TABLE tmp_cleanup_actual_fk AS
SELECT k.table_name child_table,k.column_name child_column,k.referenced_table_name parent_table,
 k.referenced_column_name parent_column,k.ordinal_position,
 k.referenced_table_schema parent_schema,r.update_rule,r.delete_rule
FROM information_schema.key_column_usage k
JOIN information_schema.referential_constraints r
 ON CAST(r.constraint_schema AS BINARY)=CAST(k.constraint_schema AS BINARY) AND CAST(r.table_name AS BINARY)=CAST(k.table_name AS BINARY) AND CAST(r.constraint_name AS BINARY)=CAST(k.constraint_name AS BINARY)
WHERE CAST(k.constraint_schema AS BINARY)=CAST(DATABASE() AS BINARY) AND k.referenced_table_name IS NOT NULL
 AND (CAST(k.table_name AS BINARY) IN ('role','user_role','privilege','role_privilege','access_rule','accessRule_privilege','accessRule_gate','accessRule_subRule')
 OR CAST(k.referenced_table_name AS BINARY) IN ('role','user_role','privilege','role_privilege','access_rule','accessRule_privilege','accessRule_gate','accessRule_subRule'));

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'required_foreign_keys', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_required_fk e LEFT JOIN tmp_cleanup_actual_fk a ON CAST(a.child_table AS BINARY)=CAST(e.child_table AS BINARY) AND CAST(a.child_column AS BINARY)=CAST(e.child_column AS BINARY) AND CAST(a.parent_table AS BINARY)=CAST(e.parent_table AS BINARY) AND CAST(a.parent_column AS BINARY)=CAST(e.parent_column AS BINARY) AND CAST(a.parent_schema AS BINARY)=CAST(DATABASE() AS BINARY) AND a.ordinal_position=1 AND a.update_rule IN ('NO ACTION','RESTRICT') AND a.delete_rule IN ('NO ACTION','RESTRICT') WHERE a.child_table IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_unexpected_foreign_keys', IF(((SELECT COUNT(*) FROM tmp_cleanup_actual_fk)=(SELECT COUNT(*) FROM tmp_cleanup_required_fk)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_external_inbound_foreign_keys', IF((NOT EXISTS (SELECT 1 FROM information_schema.key_column_usage WHERE CAST(referenced_table_schema AS BINARY)=CAST(DATABASE() AS BINARY) AND CAST(table_schema AS BINARY)<>CAST(DATABASE() AS BINARY) AND CAST(referenced_table_name AS BINARY) IN ('role','user_role','privilege','role_privilege','access_rule','accessRule_privilege','accessRule_gate','accessRule_subRule'))),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'global_innodb_inbound_foreign_keys_match', IF(((SELECT COUNT(*) FROM information_schema.INNODB_FOREIGN WHERE CAST(REF_NAME AS BINARY) IN (CONCAT(DATABASE(),'/role'),CONCAT(DATABASE(),'/user_role'),CONCAT(DATABASE(),'/privilege'),CONCAT(DATABASE(),'/role_privilege'),CONCAT(DATABASE(),'/access_rule'),CONCAT(DATABASE(),'/accessRule_privilege'),CONCAT(DATABASE(),'/accessRule_gate'),CONCAT(DATABASE(),'/accessRule_subRule'))) = (SELECT COUNT(*) FROM tmp_cleanup_required_fk WHERE parent_table IN ('role','user_role','privilege','role_privilege','access_rule','accessRule_privilege','accessRule_gate','accessRule_subRule'))),1,0);

SET @cleanup_grantee=CONCAT(QUOTE(LEFT(CURRENT_USER(),CHAR_LENGTH(CURRENT_USER())-CHAR_LENGTH(SUBSTRING_INDEX(CURRENT_USER(),'@',-1))-1)),'@',QUOTE(SUBSTRING_INDEX(CURRENT_USER(),'@',-1)));

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'trigger_metadata_visibility', IF((EXISTS (SELECT 1 FROM information_schema.SCHEMA_PRIVILEGES WHERE CAST(GRANTEE AS BINARY)=CAST(@cleanup_grantee AS BINARY) AND CAST(TABLE_SCHEMA AS BINARY)=CAST(DATABASE() AS BINARY) AND PRIVILEGE_TYPE='TRIGGER') OR (@@global.partial_revokes=0 AND EXISTS (SELECT 1 FROM information_schema.USER_PRIVILEGES WHERE CAST(GRANTEE AS BINARY)=CAST(@cleanup_grantee AS BINARY) AND PRIVILEGE_TYPE='TRIGGER'))),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_auth_cleanup_triggers', IF((NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE CAST(trigger_schema AS BINARY)=CAST(DATABASE() AS BINARY) AND CAST(event_object_table AS BINARY) IN ('user_role','role_privilege','accessRule_privilege','accessRule_gate','accessRule_subRule','access_rule','privilege','role'))),1,0);

/* InnoDB reads and candidate materialization occur in the cleanup transaction.
 * Temporary CREATE/DROP do not implicitly commit. No ALTER/TRUNCATE is used.
 * Flyway rolls back on SQL errors; a failed history entry requires operator review.
 */
SET @cleanup_original_isolation=@@transaction_isolation;
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;

/* Required baseline signatures come from the paired FISMA migrations.
 * UUIDs are deliberately not copied from an environment's audit.
 * Duplicate dictionary names represent distinct resource rules in V3.
 */
CREATE TEMPORARY TABLE tmp_cleanup_baseline_role (name VARCHAR(255),description VARCHAR(255)) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_baseline_role VALUES
('Admin','Normal admin users, can manage other users including assignment of roles and privileges'),
('MANUAL_ROLE_AUTH_ACCESS','This role will allow users to query auth HPDS based on their consents'),
('MANUAL_ROLE_NAMED_DATASET','This role will allow users to log in and query named datasets'),
('MANUAL_ROLE_OPEN_ACCESS','This role will allow users to log in and query OPEN PICSURE'),
('PIC-SURE Top Admin','PIC-SURE Auth Micro App Top admin including Admin and super Admin, can manage roles and privileges directly');

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'baseline_roles_present_unchanged', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_baseline_role b WHERE (SELECT COUNT(*) FROM role r WHERE CAST(r.name AS BINARY)=CAST(b.name AS BINARY) AND CAST(r.description AS BINARY)<=>CAST(b.description AS BINARY))<>1)),1,0);

CREATE TEMPORARY TABLE tmp_cleanup_baseline_privilege (name VARCHAR(255),description VARCHAR(255),application_name VARCHAR(255)) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_baseline_privilege VALUES
('ADMIN','PIC-SURE Auth admin for managing users.',NULL),
('AUTHORIZED_ACCESS','Privilege the UI reads to show the authorized data routes; grants nothing on its own','PICSURE'),
('MANAGED_PRIV_AUTH_ACCESS','Allow access to queries for AUTH PICSURE','PICSURE'),
('MANAGED_PRIV_DICTIONARY','Allow access to queries for Dictionary Resource','PICSURE'),
('MANAGED_PRIV_OPEN_ACCESS','Allow access to queries for OPEN PICSURE','PICSURE'),
('MANUAL_PRIV_METADATA_ACCESS','Allow access to metadata endpoint','PICSURE'),
('MANUAL_PRIV_NAMED_DATASET','Allow access to named dataset','PICSURE'),
('SUPER_ADMIN','PIC-SURE Auth super admin for managing roles/privileges/application/connections',NULL);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'baseline_privileges_present_unchanged', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_baseline_privilege b WHERE (SELECT COUNT(*) FROM privilege p LEFT JOIN application a ON a.uuid=p.application_id WHERE CAST(p.name AS BINARY)=CAST(b.name AS BINARY) AND CAST(p.description AS BINARY)<=>CAST(b.description AS BINARY) AND ((b.application_name IS NULL AND p.application_id IS NULL) OR (b.application_name IS NOT NULL AND CAST(a.name AS BINARY)=CAST(b.application_name AS BINARY))))<>1)),1,0);

CREATE TEMPORARY TABLE tmp_cleanup_baseline_rule (name VARCHAR(255),description VARCHAR(2000),rule VARCHAR(255),type INT,value VARCHAR(255),checkMapKeyOnly BIT(1),checkMapNode BIT(1),isGateAnyRelation BIT(1),isEvaluateOnlyByGates BIT(1)) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_baseline_rule VALUES
('AR_ALLOW_DICTIONARY_ACCESS','allow access to dictionary resource','$.query.resourceUUID',9,'36363664-6231-6134-2d38-6538652d3131',0,0,0,0),
('AR_ALLOW_DICTIONARY_ACCESS','allow access to dictionary resource','$.query.resourceUUID',9,'4c6e53d0-0860-4129-9bbd-568b18833f98',0,0,0,0),
('AR_ALLOW_HPDS_AUTH_INGRESS','Allow access to the authorized HPDS backend through the gateway','$.[''Target Service'']',11,'^/hpds/auth(/.*)?$',0,0,0,0),
('AR_ALLOW_HPDS_OPEN_INGRESS','Allow access to the open HPDS backend through the gateway','$.[''Target Service'']',11,'^/hpds/open(/.*)?$',0,0,0,0),
('AR_ALLOW_OPEN_ACCESS','allow access to open hpds resource','$.query.resourceUUID',9,'70c837be-5ffc-11eb-ae93-0242ac130002',0,0,0,0),
('AR_ALLOW_OPEN_ACCESS_V3','allow access to open hpds resource','$.query.resourceUUID',9,'ac004461-1b47-4832-80e2-22a4aecabe39',0,0,0,0),
('AR_ALLOW_STAT_VIS','allow access to stat vis resource','$.query.resourceUUID',9,'ca0ad4a9-130a-3a8a-ae00-e35b07f1108b',0,0,0,0),
('AR_DICTIONARY_CLEAN_PREFIX','Permit requests to dictionary endpoints via the gateway clean-prefix path','$.[''Target Service'']',11,'^/dictionary(/.*)?$',0,0,0,0),
('AR_DICTIONARY_ONLY_SEARCH','Dictionary Search','$.[''Target Service'']',6,'/search/36363664-6231-6134-2d38-6538652d3131',0,0,0,0),
('AR_DICTIONARY_ONLY_SEARCH','Dictionary Search','$.[''Target Service'']',6,'/search/4c6e53d0-0860-4129-9bbd-568b18833f98',0,0,0,0),
('AR_DICTIONARY_REQUESTS','Permit requests to dictionary endpoints','$.[''Target Service'']',11,'^/proxy/dictionary-api/.*$',0,0,0,0),
('AR_LOGGING_REQUESTS','Permit requests to logging endpoints','$.[''Target Service'']',11,'^/proxy/pic-sure-logging/.*$',0,0,0,0),
('AR_METADATA_ACCESS','Allow access to metadata endpoint','$.[''Target Service'']',11,'^/query/([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})/metadata$',0,1,0,0),
('AR_NAMED_DATASET','Allow access to named dataset','$.[''Target Service'']',11,'^/dataset/named(/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}))?$',0,1,0,0),
('AR_NAMED_DATASET_GATEWAY','Allow access to named dataset via the gateway operations path','$.[''Target Service'']',11,'^/operations/dataset/named(/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}))?$',0,1,0,0),
('AR_NO_QUERY_ACCESS','Restrict to any query endpoints','$.[''Target Service'']',1,'/query ',0,0,0,0),
('AR_NO_SEARCH','reject queries for /search',' $.[''Target Service'']',1,'/search',0,0,0,0),
('AR_ONLY_INFO','Can only do /info','$.[''Target Service'']',6,'/info',0,0,0,0),
('AR_ONLY_SEARCH','Can only do /search',' $.[''Target Service'']',6,'/search',0,0,0,0),
('AR_OPEN_ONLY_SEARCH','Open PIC-SURE Search','$.[''Target Service'']',6,'/search/70c837be-5ffc-11eb-ae93-0242ac130002',0,0,0,0),
('AR_VISUALIZATION_CLEAN_PREFIX','Permit requests to visualization endpoints via the gateway clean-prefix path','$.[''Target Service'']',11,'^/visualization(/.*)?$',0,0,0,0),
('AR_VISUALIZATION_PROXY_REQUESTS','Permit requests to visualization endpoints','$.[''Target Service'']',11,'^/?proxy/visualization/.*$',0,0,0,0),
('GATE_QUERY','triggers if user submits a query','$.[''Target Service'']',6,'/query ',0,0,0,0),
('GATE_SEARCH','Triggers on search requests',' $.[''Target Service'']',6,'/search',0,0,0,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'baseline_rules_present_unchanged', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_baseline_rule b WHERE (SELECT COUNT(*) FROM access_rule r WHERE CAST(r.name AS BINARY)=CAST(b.name AS BINARY) AND CAST(r.description AS BINARY)<=>CAST(b.description AS BINARY) AND CAST(r.rule AS BINARY)<=>CAST(b.rule AS BINARY) AND r.type<=>b.type AND CAST(r.value AS BINARY)<=>CAST(b.value AS BINARY) AND r.checkMapKeyOnly=b.checkMapKeyOnly AND r.checkMapNode=b.checkMapNode AND r.isGateAnyRelation=b.isGateAnyRelation AND r.isEvaluateOnlyByGates=b.isEvaluateOnlyByGates AND r.subAccessRuleParent_uuid IS NULL)<>1)),1,0);

CREATE TEMPORARY TABLE tmp_cleanup_protected_role (uuid BINARY(16) PRIMARY KEY) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_protected_role SELECT t.uuid FROM `role` t WHERE EXISTS (SELECT 1 FROM tmp_cleanup_baseline_role b WHERE CAST(b.name AS BINARY)=CAST(t.name AS BINARY));

CREATE TEMPORARY TABLE tmp_cleanup_protected_privilege (uuid BINARY(16) PRIMARY KEY) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_protected_privilege SELECT t.uuid FROM `privilege` t WHERE EXISTS (SELECT 1 FROM tmp_cleanup_baseline_privilege b WHERE CAST(b.name AS BINARY)=CAST(t.name AS BINARY));

CREATE TEMPORARY TABLE tmp_cleanup_protected_rule (uuid BINARY(16) PRIMARY KEY) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_protected_rule SELECT t.uuid FROM `access_rule` t WHERE EXISTS (SELECT 1 FROM tmp_cleanup_baseline_rule b WHERE CAST(b.name AS BINARY)=CAST(t.name AS BINARY));

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'baseline_role_identity_count', IF(((SELECT COUNT(*) FROM tmp_cleanup_protected_role)=5),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'baseline_privilege_identity_count', IF(((SELECT COUNT(*) FROM tmp_cleanup_protected_privilege)=8),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'baseline_rule_identity_count', IF(((SELECT COUNT(*) FROM tmp_cleanup_protected_rule)=24),1,0);

/* Candidate recognition is based on the removed generators and exact legacy shapes.
   Every candidate UUID is binary and is captured once. Unknown v2 shapes block.
   Helper shape tables contain no reviewed environment UUIDs. */
CREATE TEMPORARY TABLE tmp_cleanup_rule_signature (
    name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
    description TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
    rule_text TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
    rule_type INT NOT NULL,
    rule_value TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
    map_key TINYINT NOT NULL,
    map_node TINYINT NOT NULL,
    family VARCHAR(40) NOT NULL
) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_rule_signature VALUES
('AR_ALLOW_COUNT', 'MANAGED SUB AR to allow COUNT Queries', '$.query.query.expectedResultType', 4, 'COUNT', 0, 0, 'expected_result'),
('AR_ALLOW_CROSS_COUNT', 'MANAGED SUB AR to allow CROSS_COUNT Queries', '$.query.query.expectedResultType', 4, 'CROSS_COUNT', 0, 0, 'expected_result'),
('AR_ALLOW_CATEGORICAL_CROSS_COUNT', 'MANAGED SUB AR to allow CATEGORICAL_CROSS_COUNT Queries', '$.query.query.expectedResultType', 4, 'CATEGORICAL_CROSS_COUNT', 0, 0, 'expected_result'),
('AR_ALLOW_CONTINUOUS_CROSS_COUNT', 'MANAGED SUB AR to allow CONTINUOUS_CROSS_COUNT Queries', '$.query.query.expectedResultType', 4, 'CONTINUOUS_CROSS_COUNT', 0, 0, 'expected_result'),
('AR_ALLOW_DATAFRAME', 'MANAGED SUB AR to allow DATAFRAME Queries', '$.query.query.expectedResultType', 4, 'DATAFRAME', 0, 0, 'expected_result'),
('AR_ALLOW_DATAFRAME_PFB', 'MANAGED SUB AR to allow DATAFRAME_PFB Queries', '$.query.query.expectedResultType', 4, 'DATAFRAME_PFB', 0, 0, 'expected_result'),
('AR_ALLOW_DATAFRAME_TIMESERIES', 'MANAGED SUB AR to allow DATAFRAME_TIMESERIES Queries', '$.query.query.expectedResultType', 4, 'DATAFRAME_TIMESERIES', 0, 0, 'expected_result'),
('AR_INFO_COLUMN_LISTING', 'allow query to info_column_listing', '$.query.query.expectedResultType', 4, 'INFO_COLUMN_LISTING', 0, 1, 'info_column_listing'),
('GATE_DONOT_ALLOW_INFO_COLUMN_LISTING', 'reject info_column_listing query', '$.query.query.expectedResultType', 3, 'INFO_COLUMN_LISTING', 0, 1, 'info_column_listing_gate'),
('AR_TOPMED_RESTRICTED_CATEGORICAL', 'MANAGED SUB AR for restricting CATEGORICAL genomic concepts', '$.query.query.variantInfoFilters[*].categoryVariantInfoFilters.*', 13, NULL, 0, 0, 'topmed_restricted'),
('AR_TOPMED_RESTRICTED_NUMERIC', 'MANAGED SUB AR for restricting NUMERIC genomic concepts', '$.query.query.variantInfoFilters[*].numericVariantInfoFilters.*', 13, NULL, 0, 0, 'topmed_restricted'),
('GATE_PARENT_CONSENT_PRESENT', 'MANAGED GATE for parent study data consent present', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_consents', CHAR(92), '[*]'), 14, NULL, 0, 0, 'consent_gate'),
('GATE_PARENT_CONSENT_MISSING', 'MANAGED GATE for parent study data consent missing', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_consents', CHAR(92), '[*]'), 13, NULL, 0, 0, 'consent_gate'),
('AR_PHENO_ALLOW_PARENT_CONSENT_', 'MANAGED SUB AR for ALLOW_PARENT_CONSENT  clinical concepts', '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_consents', CHAR(92)), 1, 1, 'phenotype_consent'),
('GATE_HARMONIZED_CONSENT_PRESENT', 'MANAGED GATE for harmonized data consent present', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_harmonized_consent', CHAR(92), '[*]'), 14, NULL, 0, 0, 'consent_gate'),
('GATE_HARMONIZED_CONSENT_MISSING', 'MANAGED GATE for harmonized data consent missing', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_harmonized_consent', CHAR(92), '[*]'), 13, NULL, 0, 0, 'consent_gate'),
('AR_PHENO_ALLOW_HARMONIZED_CONSENT_', 'MANAGED SUB AR for ALLOW_HARMONIZED_CONSENT  clinical concepts', '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_harmonized_consent', CHAR(92)), 1, 1, 'phenotype_consent'),
('GATE_TOPMED_CONSENT_PRESENT', 'MANAGED GATE for Topmed data consent present', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_topmed_consents', CHAR(92), '[*]'), 14, NULL, 0, 0, 'consent_gate'),
('GATE_TOPMED_CONSENT_MISSING', 'MANAGED GATE for Topmed data consent missing', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_topmed_consents', CHAR(92), '[*]'), 13, NULL, 0, 0, 'consent_gate'),
('AR_PHENO_ALLOW_TOPMED_CONSENT_', 'MANAGED SUB AR for ALLOW_TOPMED_CONSENT  clinical concepts', '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_topmed_consents', CHAR(92)), 1, 1, 'phenotype_consent'),
('AR_PHENO_HARMONIZED_CATEGORICAL', 'MANAGED SUB AR for HARMONIZED CATEGORICAL clinical concepts', '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), 'DCC Harmonized data set', CHAR(92)), 1, 1, 'phenotype_harmonized'),
('AR_PHENO_HARMONIZED_NUMERIC', 'MANAGED SUB AR for HARMONIZED NUMERIC clinical concepts', '$.query.query.numericFilters', 15, CONCAT(CHAR(92), 'DCC Harmonized data set', CHAR(92)), 1, 1, 'phenotype_harmonized'),
('AR_PHENO_HARMONIZED_FIELDS', 'MANAGED SUB AR for HARMONIZED FIELDS clinical concepts', '$.query.query.fields.[*]', 15, CONCAT(CHAR(92), 'DCC Harmonized data set', CHAR(92)), 0, 0, 'phenotype_harmonized'),
('AR_PHENO_HARMONIZED_REQUIRED_FIELDS', 'MANAGED SUB AR for HARMONIZED REQUIRED_FIELDS clinical concepts', '$.query.query.requiredFields.[*]', 15, CONCAT(CHAR(92), 'DCC Harmonized data set', CHAR(92)), 0, 0, 'phenotype_harmonized'),
('AR_PHENO_HARMONIZED_ANY_RECORD_OF', 'MANAGED SUB AR for HARMONIZED ANY_RECORD_OF clinical concepts', '$.query.query.anyRecordOf.[*]', 15, CONCAT(CHAR(92), 'DCC Harmonized data set', CHAR(92)), 0, 0, 'phenotype_harmonized'),
('AR_PHENO_HARMONIZED_ANY_RECORD_OF_MULTI', 'MANAGED SUB AR for HARMONIZED ANY_RECORD_OF_MULTI clinical concepts', '$.query.query.anyRecordOfMulti.[*]', 15, CONCAT(CHAR(92), 'DCC Harmonized data set', CHAR(92)), 0, 0, 'phenotype_harmonized'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92), CHAR(92), '_CATEGORICAL'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92), CHAR(92), ' CATEGORICAL clinical concepts'), '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92)), 1, 1, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92), CHAR(92), '_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92), CHAR(92), ' FIELDS clinical concepts'), '$.query.query.fields.[*]', 15, CONCAT(CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92), CHAR(92), '_REQ_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92), CHAR(92), ' REQ_FIELDS clinical concepts'), '$.query.query.requiredFields.[*]', 15, CONCAT(CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92), CHAR(92), '_ANY_RECORD_OF'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92), CHAR(92), ' ANY_RECORD_OF clinical concepts'), '$.query.query.anyRecordOf.[*]', 15, CONCAT(CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92), CHAR(92), '_ANY_RECORD_OF_MULTI'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92), CHAR(92), ' ANY_RECORD_OF_MULTI clinical concepts'), '$.query.query.anyRecordOfMulti.[*]', 15, CONCAT(CHAR(92), '_Parent Study Accession with Subject ID', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92), CHAR(92), '_CATEGORICAL'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92), CHAR(92), ' CATEGORICAL clinical concepts'), '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92)), 1, 1, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92), CHAR(92), '_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92), CHAR(92), ' FIELDS clinical concepts'), '$.query.query.fields.[*]', 15, CONCAT(CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92), CHAR(92), '_REQ_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92), CHAR(92), ' REQ_FIELDS clinical concepts'), '$.query.query.requiredFields.[*]', 15, CONCAT(CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92), CHAR(92), '_ANY_RECORD_OF'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92), CHAR(92), ' ANY_RECORD_OF clinical concepts'), '$.query.query.anyRecordOf.[*]', 15, CONCAT(CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92), CHAR(92), '_ANY_RECORD_OF_MULTI'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92), CHAR(92), ' ANY_RECORD_OF_MULTI clinical concepts'), '$.query.query.anyRecordOfMulti.[*]', 15, CONCAT(CHAR(92), '_Topmed Study Accession with Subject ID', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_VCF Sample Id', CHAR(92), CHAR(92), '_CATEGORICAL'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_VCF Sample Id', CHAR(92), CHAR(92), ' CATEGORICAL clinical concepts'), '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_VCF Sample Id', CHAR(92)), 1, 1, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_VCF Sample Id', CHAR(92), CHAR(92), '_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_VCF Sample Id', CHAR(92), CHAR(92), ' FIELDS clinical concepts'), '$.query.query.fields.[*]', 15, CONCAT(CHAR(92), '_VCF Sample Id', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_VCF Sample Id', CHAR(92), CHAR(92), '_REQ_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_VCF Sample Id', CHAR(92), CHAR(92), ' REQ_FIELDS clinical concepts'), '$.query.query.requiredFields.[*]', 15, CONCAT(CHAR(92), '_VCF Sample Id', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_VCF Sample Id', CHAR(92), CHAR(92), '_ANY_RECORD_OF'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_VCF Sample Id', CHAR(92), CHAR(92), ' ANY_RECORD_OF clinical concepts'), '$.query.query.anyRecordOf.[*]', 15, CONCAT(CHAR(92), '_VCF Sample Id', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_VCF Sample Id', CHAR(92), CHAR(92), '_ANY_RECORD_OF_MULTI'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_VCF Sample Id', CHAR(92), CHAR(92), ' ANY_RECORD_OF_MULTI clinical concepts'), '$.query.query.anyRecordOfMulti.[*]', 15, CONCAT(CHAR(92), '_VCF Sample Id', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_studies', CHAR(92), CHAR(92), '_CATEGORICAL'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_studies', CHAR(92), CHAR(92), ' CATEGORICAL clinical concepts'), '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_studies', CHAR(92)), 1, 1, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_studies', CHAR(92), CHAR(92), '_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_studies', CHAR(92), CHAR(92), ' FIELDS clinical concepts'), '$.query.query.fields.[*]', 15, CONCAT(CHAR(92), '_studies', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_studies', CHAR(92), CHAR(92), '_REQ_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_studies', CHAR(92), CHAR(92), ' REQ_FIELDS clinical concepts'), '$.query.query.requiredFields.[*]', 15, CONCAT(CHAR(92), '_studies', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_studies', CHAR(92), CHAR(92), '_ANY_RECORD_OF'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_studies', CHAR(92), CHAR(92), ' ANY_RECORD_OF clinical concepts'), '$.query.query.anyRecordOf.[*]', 15, CONCAT(CHAR(92), '_studies', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_studies', CHAR(92), CHAR(92), '_ANY_RECORD_OF_MULTI'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_studies', CHAR(92), CHAR(92), ' ANY_RECORD_OF_MULTI clinical concepts'), '$.query.query.anyRecordOfMulti.[*]', 15, CONCAT(CHAR(92), '_studies', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_studies_consents', CHAR(92), CHAR(92), '_CATEGORICAL'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_studies_consents', CHAR(92), CHAR(92), ' CATEGORICAL clinical concepts'), '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_studies_consents', CHAR(92)), 1, 1, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_studies_consents', CHAR(92), CHAR(92), '_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_studies_consents', CHAR(92), CHAR(92), ' FIELDS clinical concepts'), '$.query.query.fields.[*]', 15, CONCAT(CHAR(92), '_studies_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_studies_consents', CHAR(92), CHAR(92), '_REQ_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_studies_consents', CHAR(92), CHAR(92), ' REQ_FIELDS clinical concepts'), '$.query.query.requiredFields.[*]', 15, CONCAT(CHAR(92), '_studies_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_studies_consents', CHAR(92), CHAR(92), '_ANY_RECORD_OF'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_studies_consents', CHAR(92), CHAR(92), ' ANY_RECORD_OF clinical concepts'), '$.query.query.anyRecordOf.[*]', 15, CONCAT(CHAR(92), '_studies_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_studies_consents', CHAR(92), CHAR(92), '_ANY_RECORD_OF_MULTI'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_studies_consents', CHAR(92), CHAR(92), ' ANY_RECORD_OF_MULTI clinical concepts'), '$.query.query.anyRecordOfMulti.[*]', 15, CONCAT(CHAR(92), '_studies_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_parent_consents', CHAR(92), CHAR(92), '_CATEGORICAL'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_parent_consents', CHAR(92), CHAR(92), ' CATEGORICAL clinical concepts'), '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_parent_consents', CHAR(92)), 1, 1, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_parent_consents', CHAR(92), CHAR(92), '_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_parent_consents', CHAR(92), CHAR(92), ' FIELDS clinical concepts'), '$.query.query.fields.[*]', 15, CONCAT(CHAR(92), '_parent_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_parent_consents', CHAR(92), CHAR(92), '_REQ_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_parent_consents', CHAR(92), CHAR(92), ' REQ_FIELDS clinical concepts'), '$.query.query.requiredFields.[*]', 15, CONCAT(CHAR(92), '_parent_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_parent_consents', CHAR(92), CHAR(92), '_ANY_RECORD_OF'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_parent_consents', CHAR(92), CHAR(92), ' ANY_RECORD_OF clinical concepts'), '$.query.query.anyRecordOf.[*]', 15, CONCAT(CHAR(92), '_parent_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_parent_consents', CHAR(92), CHAR(92), '_ANY_RECORD_OF_MULTI'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_parent_consents', CHAR(92), CHAR(92), ' ANY_RECORD_OF_MULTI clinical concepts'), '$.query.query.anyRecordOfMulti.[*]', 15, CONCAT(CHAR(92), '_parent_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Consents', CHAR(92), CHAR(92), '_CATEGORICAL'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Consents', CHAR(92), CHAR(92), ' CATEGORICAL clinical concepts'), '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_Consents', CHAR(92)), 1, 1, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Consents', CHAR(92), CHAR(92), '_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Consents', CHAR(92), CHAR(92), ' FIELDS clinical concepts'), '$.query.query.fields.[*]', 15, CONCAT(CHAR(92), '_Consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Consents', CHAR(92), CHAR(92), '_REQ_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Consents', CHAR(92), CHAR(92), ' REQ_FIELDS clinical concepts'), '$.query.query.requiredFields.[*]', 15, CONCAT(CHAR(92), '_Consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Consents', CHAR(92), CHAR(92), '_ANY_RECORD_OF'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Consents', CHAR(92), CHAR(92), ' ANY_RECORD_OF clinical concepts'), '$.query.query.anyRecordOf.[*]', 15, CONCAT(CHAR(92), '_Consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), CHAR(92), '_Consents', CHAR(92), CHAR(92), '_ANY_RECORD_OF_MULTI'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), CHAR(92), '_Consents', CHAR(92), CHAR(92), ' ANY_RECORD_OF_MULTI clinical concepts'), '$.query.query.anyRecordOfMulti.[*]', 15, CONCAT(CHAR(92), '_Consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_harmonized_consent', CHAR(92), '_CATEGORICAL'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_harmonized_consent', CHAR(92), ' CATEGORICAL clinical concepts'), '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_harmonized_consent', CHAR(92)), 1, 1, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_harmonized_consent', CHAR(92), '_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_harmonized_consent', CHAR(92), ' FIELDS clinical concepts'), '$.query.query.fields.[*]', 15, CONCAT(CHAR(92), '_harmonized_consent', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_harmonized_consent', CHAR(92), '_REQ_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_harmonized_consent', CHAR(92), ' REQ_FIELDS clinical concepts'), '$.query.query.requiredFields.[*]', 15, CONCAT(CHAR(92), '_harmonized_consent', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_harmonized_consent', CHAR(92), '_ANY_RECORD_OF'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_harmonized_consent', CHAR(92), ' ANY_RECORD_OF clinical concepts'), '$.query.query.anyRecordOf.[*]', 15, CONCAT(CHAR(92), '_harmonized_consent', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_harmonized_consent', CHAR(92), '_ANY_RECORD_OF_MULTI'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_harmonized_consent', CHAR(92), ' ANY_RECORD_OF_MULTI clinical concepts'), '$.query.query.anyRecordOfMulti.[*]', 15, CONCAT(CHAR(92), '_harmonized_consent', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_consents', CHAR(92), '_CATEGORICAL'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_consents', CHAR(92), ' CATEGORICAL clinical concepts'), '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_consents', CHAR(92)), 1, 1, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_consents', CHAR(92), '_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_consents', CHAR(92), ' FIELDS clinical concepts'), '$.query.query.fields.[*]', 15, CONCAT(CHAR(92), '_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_consents', CHAR(92), '_REQ_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_consents', CHAR(92), ' REQ_FIELDS clinical concepts'), '$.query.query.requiredFields.[*]', 15, CONCAT(CHAR(92), '_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_consents', CHAR(92), '_ANY_RECORD_OF'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_consents', CHAR(92), ' ANY_RECORD_OF clinical concepts'), '$.query.query.anyRecordOf.[*]', 15, CONCAT(CHAR(92), '_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_consents', CHAR(92), '_ANY_RECORD_OF_MULTI'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_consents', CHAR(92), ' ANY_RECORD_OF_MULTI clinical concepts'), '$.query.query.anyRecordOfMulti.[*]', 15, CONCAT(CHAR(92), '_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_topmed_consents', CHAR(92), '_CATEGORICAL'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_topmed_consents', CHAR(92), ' CATEGORICAL clinical concepts'), '$.query.query.categoryFilters', 5, CONCAT(CHAR(92), '_topmed_consents', CHAR(92)), 1, 1, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_topmed_consents', CHAR(92), '_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_topmed_consents', CHAR(92), ' FIELDS clinical concepts'), '$.query.query.fields.[*]', 15, CONCAT(CHAR(92), '_topmed_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_topmed_consents', CHAR(92), '_REQ_FIELDS'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_topmed_consents', CHAR(92), ' REQ_FIELDS clinical concepts'), '$.query.query.requiredFields.[*]', 15, CONCAT(CHAR(92), '_topmed_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_topmed_consents', CHAR(92), '_ANY_RECORD_OF'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_topmed_consents', CHAR(92), ' ANY_RECORD_OF clinical concepts'), '$.query.query.anyRecordOf.[*]', 15, CONCAT(CHAR(92), '_topmed_consents', CHAR(92)), 0, 0, 'phenotype_underscore'),
(CONCAT('AR_PHENO_ALLOW ', CHAR(92), '_topmed_consents', CHAR(92), '_ANY_RECORD_OF_MULTI'), CONCAT('MANAGED SUB AR for ALLOW ', CHAR(92), '_topmed_consents', CHAR(92), ' ANY_RECORD_OF_MULTI clinical concepts'), '$.query.query.anyRecordOfMulti.[*]', 15, CONCAT(CHAR(92), '_topmed_consents', CHAR(92)), 0, 0, 'phenotype_underscore');

CREATE TEMPORARY TABLE tmp_cleanup_rule_shape (
 uuid BINARY(16) PRIMARY KEY,
 name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
 family VARCHAR(40) NOT NULL
) ENGINE=InnoDB;
INSERT INTO tmp_cleanup_rule_shape (uuid, name, family)
SELECT ar.uuid, ar.name, s.family
FROM access_rule ar
JOIN tmp_cleanup_rule_signature s
  ON CAST(ar.name AS BINARY) = CAST(s.name AS BINARY)
 AND CAST(ar.description AS BINARY) = CAST(s.description AS BINARY)
 AND CAST(ar.rule AS BINARY) = CAST(s.rule_text AS BINARY)
 AND ar.type = s.rule_type
 AND (CAST(ar.value AS BINARY) <=> CAST(s.rule_value AS BINARY))
 AND ar.checkMapKeyOnly = s.map_key AND ar.checkMapNode = s.map_node
WHERE ar.isGateAnyRelation = 0 AND ar.isEvaluateOnlyByGates = 0
  AND ar.subAccessRuleParent_uuid IS NULL;

CREATE TEMPORARY TABLE tmp_cleanup_consent_shape (
 family VARCHAR(40) NOT NULL,
 name_prefix VARCHAR(30) NOT NULL,
 name_suffix VARCHAR(30) NOT NULL,
 path TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
 allow_empty_consent TINYINT NOT NULL
) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_consent_shape VALUES
('consent', 'AR_CONSENT_', '_PARENT', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_consents', CHAR(92), '[*]'), 0),
('consent', 'AR_CONSENT_', '_HARMONIZED', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_harmonized_consent', CHAR(92), '[*]'), 0),
('consent_empty', 'AR_CONSENT_', '', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_consents', CHAR(92), '[*]'), 1),
('consent_empty', 'AR_CONSENT_', '', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_harmonized_consent', CHAR(92), '[*]'), 1),
('topmed', 'AR_TOPMED_', '_TOPMED', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_topmed_consents', CHAR(92), '[*]'), 0),
('topmed_empty', 'AR_TOPMED_', '_TOPMED', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_topmed_consents', CHAR(92), '[*]'), 1),
('topmed', 'AR_TOPMED_', '_TOPMED+PARENT', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_topmed_consents', CHAR(92), '[*]'), 0),
('topmed_empty', 'AR_TOPMED_', '_TOPMED+PARENT', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_topmed_consents', CHAR(92), '[*]'), 1),
('topmed', 'AR_TOPMED_', '_HARMONIZED', CONCAT('$.query.query.categoryFilters.', CHAR(92), '_harmonized_consent', CHAR(92), '[*]'), 0);

INSERT INTO tmp_cleanup_rule_shape (uuid, name, family)
SELECT DISTINCT ar.uuid, ar.name, s.family
FROM access_rule ar JOIN tmp_cleanup_consent_shape s
 ON CAST(ar.rule AS BINARY) = CAST(s.path AS BINARY)
 AND CAST(ar.name AS BINARY) = CAST(CONCAT(s.name_prefix, REPLACE(ar.value, '.', '_'), s.name_suffix) AS BINARY)
 AND CAST(ar.description AS BINARY) = CAST(CONCAT('MANAGED AR for ', ar.value,
     IF(s.family = 'topmed_empty', '.', ''),
     IF(s.family IN ('topmed','topmed_empty'), ' Topmed data', ' clinical concepts')) AS BINARY)
WHERE ar.type = 5 AND ar.checkMapKeyOnly = 0 AND ar.checkMapNode = 0
 AND ar.isGateAnyRelation = 0 AND ar.isEvaluateOnlyByGates = 0
 AND ar.subAccessRuleParent_uuid IS NULL
 AND ((s.allow_empty_consent = 0 AND REGEXP_LIKE(ar.value, '^[A-Za-z0-9][A-Za-z0-9_-]*[.]c[0-9]+$', 'c'))
   OR (s.allow_empty_consent = 1 AND REGEXP_LIKE(ar.value, '^[A-Za-z0-9][A-Za-z0-9_-]*$', 'c')));

CREATE TEMPORARY TABLE tmp_cleanup_phenotype_suffix (
 label VARCHAR(40) PRIMARY KEY,
 rule_text VARCHAR(100) NOT NULL,
 rule_type INT NOT NULL,
 map_flag TINYINT NOT NULL
) ENGINE=InnoDB;

INSERT INTO tmp_cleanup_phenotype_suffix VALUES
('CATEGORICAL', '$.query.query.categoryFilters', 5, 1),
('NUMERIC', '$.query.query.numericFilters', 15, 1),
('FIELDS', '$.query.query.fields.[*]', 15, 0),
('REQUIRED_FIELDS', '$.query.query.requiredFields.[*]', 15, 0),
('ANY_RECORD_OF', '$.query.query.anyRecordOf.[*]', 15, 0),
('ANY_RECORD_OF_MULTI', '$.query.query.anyRecordOfMulti.[*]', 15, 0);

/* Study phenotype rules encode the same study in the alias and the concept value.
   The accepted shape has one top-level path segment, as in the reviewed data. */
INSERT INTO tmp_cleanup_rule_shape (uuid, name, family)
SELECT ar.uuid, ar.name, 'phenotype_study'
FROM access_rule ar JOIN tmp_cleanup_phenotype_suffix s
 ON CAST(ar.rule AS BINARY) = CAST(s.rule_text AS BINARY)
 AND ar.type = s.rule_type AND ar.checkMapKeyOnly = s.map_flag AND ar.checkMapNode = s.map_flag
WHERE CAST(LEFT(ar.name,9) AS BINARY) = CAST('AR_PHENO_' AS BINARY)
 AND CAST(RIGHT(ar.name, CHAR_LENGTH(s.label) + 1) AS BINARY) = CAST(CONCAT('_',s.label) AS BINARY)
 AND CAST(ar.description AS BINARY) = CAST(CONCAT('MANAGED SUB AR for ',
       SUBSTRING(ar.name,10,CHAR_LENGTH(ar.name)-10-CHAR_LENGTH(s.label)), ' ',s.label,' clinical concepts') AS BINARY)
 AND LEFT(ar.value,1) = CHAR(92) AND RIGHT(ar.value,1) = CHAR(92)
 AND REGEXP_LIKE(SUBSTRING(ar.value,2,CHAR_LENGTH(ar.value)-2), '^[A-Za-z0-9][A-Za-z0-9_-]*$', 'c')
 AND CAST(RIGHT(SUBSTRING(ar.name,10,CHAR_LENGTH(ar.name)-10-CHAR_LENGTH(s.label)),CHAR_LENGTH(ar.value)-1) AS BINARY)
       = CAST(CONCAT('_',SUBSTRING(ar.value,2,CHAR_LENGTH(ar.value)-2)) AS BINARY)
 AND CHAR_LENGTH(SUBSTRING(ar.name,10,CHAR_LENGTH(ar.name)-10-CHAR_LENGTH(s.label))) > CHAR_LENGTH(ar.value)-1
 AND ar.isGateAnyRelation = 0 AND ar.isEvaluateOnlyByGates = 0 AND ar.subAccessRuleParent_uuid IS NULL;

CREATE TEMPORARY TABLE tmp_cleanup_restricted_suffix (
 label VARCHAR(40) PRIMARY KEY, rule_text VARCHAR(100) NOT NULL
) ENGINE=InnoDB;
INSERT INTO tmp_cleanup_restricted_suffix VALUES
 ('DISALLOW_NUMERIC','$.query.query.numericFilters.[*]'),
 ('DISALLOW_REQUIRED_FIELDS','$.query.query.requiredFields.[*]');
CREATE TEMPORARY TABLE tmp_cleanup_topmed_parent LIKE tmp_cleanup_rule_shape;
INSERT INTO tmp_cleanup_topmed_parent SELECT * FROM tmp_cleanup_rule_shape WHERE family IN ('topmed','topmed_empty');
/* Restricted phenotype aliases must correspond to a verified Topmed parent. */
INSERT INTO tmp_cleanup_rule_shape (uuid, name, family)
SELECT DISTINCT ar.uuid, ar.name, 'phenotype_restricted'
FROM access_rule ar JOIN tmp_cleanup_restricted_suffix s
 ON CAST(ar.rule AS BINARY) = CAST(s.rule_text AS BINARY)
JOIN accessRule_subRule rel ON rel.subRule_id = ar.uuid
JOIN access_rule parent ON parent.uuid = rel.accessRule_id
JOIN tmp_cleanup_topmed_parent ps ON ps.uuid = parent.uuid
WHERE ps.family IN ('topmed','topmed_empty')
 AND CAST(LEFT(ar.name,9) AS BINARY) = CAST('AR_PHENO_' AS BINARY)
 AND CAST(RIGHT(ar.name,CHAR_LENGTH(s.label)+1) AS BINARY) = CAST(CONCAT('_',s.label) AS BINARY)
 AND CAST(ar.description AS BINARY) = CAST(CONCAT('MANAGED SUB AR for ',
       SUBSTRING(ar.name,10,CHAR_LENGTH(ar.name)-10-CHAR_LENGTH(s.label)), ' ',s.label,' clinical concepts') AS BINARY)
 AND CAST(RIGHT(SUBSTRING(ar.name,10,CHAR_LENGTH(ar.name)-10-CHAR_LENGTH(s.label)),
       CHAR_LENGTH(REPLACE(parent.value,'.','_'))+1+IF(ps.family='topmed_empty',1,0)) AS BINARY)
       = CAST(CONCAT('_',REPLACE(parent.value,'.','_'),IF(ps.family='topmed_empty','_', '')) AS BINARY)
 AND ar.type = 13 AND ar.value IS NULL AND ar.checkMapKeyOnly = 0 AND ar.checkMapNode = 0
 AND ar.isGateAnyRelation = 0 AND ar.isEvaluateOnlyByGates = 0 AND ar.subAccessRuleParent_uuid IS NULL;

CREATE TEMPORARY TABLE tmp_cleanup_v2_rule LIKE tmp_cleanup_rule_shape;
INSERT INTO tmp_cleanup_v2_rule SELECT * FROM tmp_cleanup_rule_shape;
CREATE TEMPORARY TABLE tmp_cleanup_privilege_shape (
 uuid BINARY(16) PRIMARY KEY,
 name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
 family VARCHAR(40) NOT NULL,
 study_key VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=InnoDB;
INSERT INTO tmp_cleanup_privilege_shape (uuid,name,family,study_key)
SELECT p.uuid,p.name,
 CASE WHEN RIGHT(p.name,7)='_TOPMED' THEN 'topmed' WHEN RIGHT(p.name,11)='_HARMONIZED' THEN 'harmonized' ELSE 'clinical' END,
 CASE WHEN RIGHT(p.name,8)='__TOPMED' THEN SUBSTRING(p.name,14,CHAR_LENGTH(p.name)-21)
      WHEN RIGHT(p.name,7)='_TOPMED' THEN SUBSTRING(p.name,14,CHAR_LENGTH(p.name)-20)
      WHEN RIGHT(p.name,11)='_HARMONIZED' THEN SUBSTRING(p.name,14,CHAR_LENGTH(p.name)-24)
      ELSE SUBSTRING(p.name,14) END
FROM privilege p JOIN application app ON app.uuid=p.application_id
WHERE CAST(LEFT(p.name,13) AS BINARY)=CAST('PRIV_MANAGED_' AS BINARY)
 AND CAST(app.name AS BINARY)=CAST('PICSURE' AS BINARY)
 AND REGEXP_LIKE(SUBSTRING(p.name,14),'^[A-Za-z0-9][A-Za-z0-9_-]*$', 'c');
CREATE TEMPORARY TABLE tmp_cleanup_stale_privilege LIKE tmp_cleanup_privilege_shape;
INSERT INTO tmp_cleanup_stale_privilege
SELECT ps.* FROM tmp_cleanup_privilege_shape ps JOIN privilege p ON p.uuid=ps.uuid
WHERE ((ps.family IN ('clinical','harmonized') AND p.description IS NULL)
 OR (ps.family='topmed' AND CAST(p.description AS BINARY)=CAST(CONCAT('MANAGED privilege for Topmed ',
  REGEXP_REPLACE(ps.study_key,'_c([0-9]+)$','.c$1')) AS BINARY)))
 AND EXISTS (
 SELECT 1 FROM accessRule_privilege rel
 JOIN access_rule ar ON ar.uuid=rel.accessRule_id
 JOIN tmp_cleanup_v2_rule cr ON cr.uuid=ar.uuid
 WHERE rel.privilege_id=ps.uuid
 AND ((ps.family IN ('clinical','harmonized') AND cr.family IN ('consent','consent_empty')
   AND CAST(ar.name AS BINARY)=CAST(CONCAT('AR_CONSENT_',ps.study_key,
     IF(cr.family='consent_empty','',IF(ps.family='harmonized','_HARMONIZED','_PARENT'))) AS BINARY))
 OR (ps.family='topmed' AND cr.family IN ('topmed','topmed_empty')
   AND CAST(ar.name AS BINARY)=CAST(CONCAT('AR_TOPMED_',ps.study_key,'_TOPMED') AS BINARY))));
CREATE TEMPORARY TABLE tmp_cleanup_role_classification (
 uuid BINARY(16) PRIMARY KEY,
 name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
 family VARCHAR(40) NOT NULL
) ENGINE=InnoDB;
INSERT INTO tmp_cleanup_role_classification
SELECT r.uuid,r.name,
CASE
 WHEN CAST(r.name AS BINARY) IN ('MANUAL_ROLE_AUTH_ACCESS','MANUAL_ROLE_OPEN_ACCESS','MANUAL_ROLE_NAMED_DATASET',
    'MANAGED_ROLE_OPEN_ACCESS','FENCE_ROLE_OPEN_ACCESS','PIC-SURE Top Admin','Admin') THEN 'protected'
 WHEN (CAST(LEFT(r.name,8) AS BINARY)='MANAGED_' AND CAST(r.description AS BINARY)=CAST(CONCAT('MANAGED role ',r.name) AS BINARY)
    OR CAST(LEFT(r.name,7) AS BINARY)='MANUAL_' AND CAST(r.description AS BINARY)=CAST(CONCAT('MANUAL_ role ',r.name) AS BINARY))
  AND REGEXP_LIKE(SUBSTRING(r.name,IF(LEFT(r.name,8)='MANAGED_',9,8)),'^[A-Za-z0-9][A-Za-z0-9_-]*$', 'c')
  AND NOT EXISTS (
   SELECT 1 FROM role_privilege rp LEFT JOIN tmp_cleanup_stale_privilege cp ON cp.uuid=rp.privilege_id
   WHERE rp.role_id=r.uuid AND (cp.uuid IS NULL OR
    CAST(cp.study_key AS BINARY)<>CAST(SUBSTRING(r.name,IF(LEFT(r.name,8)='MANAGED_',9,8)) AS BINARY)))
 AND (LEFT(r.name,8)='MANAGED_' OR EXISTS (SELECT 1 FROM role_privilege rp WHERE rp.role_id=r.uuid))
 THEN IF(LEFT(r.name,8)='MANAGED_','generated_managed','generated_manual')
 WHEN LEFT(r.name,8)='MANAGED_' OR LEFT(r.name,7)='MANUAL_' THEN 'ambiguous'
 ELSE 'protected'
END
FROM role r;
CREATE TEMPORARY TABLE tmp_cleanup_generated_role LIKE tmp_cleanup_role_classification;
INSERT INTO tmp_cleanup_generated_role SELECT * FROM tmp_cleanup_role_classification WHERE family IN ('generated_managed','generated_manual');
CREATE TEMPORARY TABLE tmp_cleanup_classification_blocker (
 entity_type VARCHAR(30) NOT NULL,
 uuid BINARY(16) NOT NULL,
 name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
 reason VARCHAR(255) NOT NULL
) ENGINE=InnoDB;
INSERT INTO tmp_cleanup_classification_blocker
SELECT 'role', uuid,name,'Generated role has unproven metadata, custom privileges, or mismatched study privileges'
FROM tmp_cleanup_role_classification WHERE family='ambiguous';
INSERT INTO tmp_cleanup_classification_blocker
SELECT 'privilege',p.uuid,p.name,'Stale privilege namespace has unproven metadata or lacks its exact generated main rule'
FROM privilege p LEFT JOIN tmp_cleanup_stale_privilege cp ON cp.uuid=p.uuid
WHERE CAST(LEFT(p.name,13) AS BINARY)='PRIV_MANAGED_' AND cp.uuid IS NULL;
CREATE TEMPORARY TABLE tmp_cleanup_rule_classification LIKE tmp_cleanup_role_classification;
INSERT INTO tmp_cleanup_rule_classification
SELECT ar.uuid, ar.name,
CASE
 WHEN ar.rule IS NULL THEN 'excluded_null_rule'
 WHEN ar.type = 17 THEN 'excluded_type_17'
 WHEN cr.uuid IS NOT NULL THEN 'generated_v2'
 WHEN CAST(LEFT(REGEXP_REPLACE(ar.rule,'^[[:space:]]+',''),13) AS BINARY)='$.query.query'
  OR CAST(LEFT(ar.name,9) AS BINARY)='AR_PHENO_'
  OR CAST(LEFT(ar.name,11) AS BINARY)='AR_CONSENT_'
  OR CAST(LEFT(ar.name,10) AS BINARY)='AR_TOPMED_'
  OR EXISTS (SELECT 1 FROM tmp_cleanup_rule_signature sig WHERE CAST(sig.name AS BINARY)=CAST(ar.name AS BINARY))
 THEN 'ambiguous'
 ELSE 'preserved'
END
FROM access_rule ar LEFT JOIN tmp_cleanup_v2_rule cr ON cr.uuid=ar.uuid;
INSERT INTO tmp_cleanup_classification_blocker
SELECT 'access_rule',uuid,name,'Unclassified v2 query or generated rule shape'
FROM tmp_cleanup_rule_classification WHERE family='ambiguous';
/* The migration must hard-assert this count is zero before the first base-table DELETE. */
SELECT entity_type, HEX(uuid) AS uuid_hex, name, reason
FROM tmp_cleanup_classification_blocker ORDER BY entity_type,name,uuid;

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_accessRule_gate_gate_id', IF((NOT EXISTS (SELECT 1 FROM `accessRule_gate` c LEFT JOIN `access_rule` p ON p.`uuid`=c.`gate_id` WHERE c.`gate_id` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_accessRule_gate_accessRule_id', IF((NOT EXISTS (SELECT 1 FROM `accessRule_gate` c LEFT JOIN `access_rule` p ON p.`uuid`=c.`accessRule_id` WHERE c.`accessRule_id` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_accessRule_privilege_privilege_id', IF((NOT EXISTS (SELECT 1 FROM `accessRule_privilege` c LEFT JOIN `privilege` p ON p.`uuid`=c.`privilege_id` WHERE c.`privilege_id` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_accessRule_privilege_accessRule_id', IF((NOT EXISTS (SELECT 1 FROM `accessRule_privilege` c LEFT JOIN `access_rule` p ON p.`uuid`=c.`accessRule_id` WHERE c.`accessRule_id` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_accessRule_subRule_subRule_id', IF((NOT EXISTS (SELECT 1 FROM `accessRule_subRule` c LEFT JOIN `access_rule` p ON p.`uuid`=c.`subRule_id` WHERE c.`subRule_id` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_accessRule_subRule_accessRule_id', IF((NOT EXISTS (SELECT 1 FROM `accessRule_subRule` c LEFT JOIN `access_rule` p ON p.`uuid`=c.`accessRule_id` WHERE c.`accessRule_id` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_access_rule_subAccessRuleParent_uuid', IF((NOT EXISTS (SELECT 1 FROM `access_rule` c LEFT JOIN `access_rule` p ON p.`uuid`=c.`subAccessRuleParent_uuid` WHERE c.`subAccessRuleParent_uuid` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_privilege_application_id', IF((NOT EXISTS (SELECT 1 FROM `privilege` c LEFT JOIN `application` p ON p.`uuid`=c.`application_id` WHERE c.`application_id` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_role_privilege_privilege_id', IF((NOT EXISTS (SELECT 1 FROM `role_privilege` c LEFT JOIN `privilege` p ON p.`uuid`=c.`privilege_id` WHERE c.`privilege_id` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_role_privilege_role_id', IF((NOT EXISTS (SELECT 1 FROM `role_privilege` c LEFT JOIN `role` p ON p.`uuid`=c.`role_id` WHERE c.`role_id` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_user_role_user_id', IF((NOT EXISTS (SELECT 1 FROM `user_role` c LEFT JOIN `user` p ON p.`uuid`=c.`user_id` WHERE c.`user_id` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_orphan_user_role_role_id', IF((NOT EXISTS (SELECT 1 FROM `user_role` c LEFT JOIN `role` p ON p.`uuid`=c.`role_id` WHERE c.`role_id` IS NOT NULL AND p.`uuid` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'classification_unambiguous', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_classification_blocker)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'baseline_privilege_not_selected', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_stale_privilege c JOIN tmp_cleanup_protected_privilege p ON p.uuid=c.uuid)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'baseline_role_not_selected', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_generated_role c JOIN tmp_cleanup_protected_role p ON p.uuid=c.uuid)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'baseline_rule_not_selected', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_v2_rule c JOIN tmp_cleanup_protected_rule p ON p.uuid=c.uuid)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_query_rule_unclassified', IF((NOT EXISTS (SELECT 1 FROM access_rule a LEFT JOIN tmp_cleanup_v2_rule c ON c.uuid=a.uuid WHERE LEFT(REGEXP_REPLACE(a.rule,'^[[:space:]]+',''),13)='$.query.query' AND a.type<>17 AND c.uuid IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'stale_privilege_names_unambiguous', IF((NOT EXISTS (SELECT name FROM tmp_cleanup_stale_privilege GROUP BY name HAVING COUNT(*)>1)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'generated_role_names_unambiguous', IF((NOT EXISTS (SELECT name FROM tmp_cleanup_generated_role GROUP BY name HAVING COUNT(*)>1)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'v2_rule_names_unambiguous', IF((NOT EXISTS (SELECT name FROM tmp_cleanup_v2_rule GROUP BY name HAVING COUNT(*)>1)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_stale_privilege_on_unreviewed_retained_role', IF((NOT EXISTS (SELECT 1 FROM role_privilege e JOIN tmp_cleanup_stale_privilege p ON p.uuid=e.privilege_id LEFT JOIN tmp_cleanup_generated_role c ON c.uuid=e.role_id JOIN role r ON r.uuid=e.role_id WHERE c.uuid IS NULL AND NOT COALESCE(CAST(r.name AS BINARY) IN ('Admin','PIC-SURE Top Admin'),0))),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_v2_rule_on_live_privilege', IF((NOT EXISTS (SELECT 1 FROM accessRule_privilege e JOIN tmp_cleanup_v2_rule c ON c.uuid=e.accessRule_id LEFT JOIN tmp_cleanup_stale_privilege p ON p.uuid=e.privilege_id WHERE p.uuid IS NULL AND c.name<>'AR_INFO_COLUMN_LISTING')),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'stale_privilege_only_generated_or_standard_rules', IF((NOT EXISTS (SELECT 1 FROM accessRule_privilege e JOIN tmp_cleanup_stale_privilege p ON p.uuid=e.privilege_id LEFT JOIN tmp_cleanup_v2_rule c ON c.uuid=e.accessRule_id JOIN access_rule a ON a.uuid=e.accessRule_id WHERE c.uuid IS NULL AND (a.name IS NULL OR CAST(a.name AS BINARY) NOT IN ('AR_ONLY_INFO','AR_ONLY_SEARCH','AR_DICTIONARY_REQUESTS','AR_LOGGING_REQUESTS')))),1,0);

CREATE TEMPORARY TABLE tmp_cleanup_accessRule_gate_scope (
 accessRule_id BINARY(16), `gate_id` BINARY(16), candidates INT NOT NULL,
 PRIMARY KEY(accessRule_id,`gate_id`)
) ENGINE=InnoDB;
INSERT INTO tmp_cleanup_accessRule_gate_scope
SELECT e.accessRule_id,e.`gate_id`,0 FROM `accessRule_gate` e;
UPDATE tmp_cleanup_accessRule_gate_scope e JOIN tmp_cleanup_v2_rule c ON c.uuid=e.accessRule_id SET e.candidates=1;
UPDATE tmp_cleanup_accessRule_gate_scope e JOIN tmp_cleanup_v2_rule c ON c.uuid=e.`gate_id` SET e.candidates=e.candidates+IF(e.accessRule_id=e.`gate_id`,0,1);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'accessRule_gate_does_not_cross_candidate_boundary', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_accessRule_gate_scope WHERE candidates<>0 AND candidates<>IF(accessRule_id=`gate_id`,1,2))),1,0);

CREATE TEMPORARY TABLE tmp_cleanup_accessRule_subRule_scope (
 accessRule_id BINARY(16), `subRule_id` BINARY(16), candidates INT NOT NULL,
 PRIMARY KEY(accessRule_id,`subRule_id`)
) ENGINE=InnoDB;
INSERT INTO tmp_cleanup_accessRule_subRule_scope
SELECT e.accessRule_id,e.`subRule_id`,0 FROM `accessRule_subRule` e;
UPDATE tmp_cleanup_accessRule_subRule_scope e JOIN tmp_cleanup_v2_rule c ON c.uuid=e.accessRule_id SET e.candidates=1;
UPDATE tmp_cleanup_accessRule_subRule_scope e JOIN tmp_cleanup_v2_rule c ON c.uuid=e.`subRule_id` SET e.candidates=e.candidates+IF(e.accessRule_id=e.`subRule_id`,0,1);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'accessRule_subRule_does_not_cross_candidate_boundary', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_accessRule_subRule_scope WHERE candidates<>0 AND candidates<>IF(accessRule_id=`subRule_id`,1,2))),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_candidate_parent_pointer', IF((NOT EXISTS (SELECT 1 FROM access_rule a WHERE a.subAccessRuleParent_uuid IS NOT NULL AND EXISTS (SELECT 1 FROM tmp_cleanup_v2_rule c WHERE c.uuid=a.uuid OR c.uuid=a.subAccessRuleParent_uuid))),1,0);

SELECT 'NULL_RULES_PRESERVED' AS diagnostic,COUNT(*) AS row_count FROM access_rule WHERE rule IS NULL;

SELECT 'ADMIN_ROLE_STALE_PRIVILEGE_DETACHED' AS diagnostic, r.name AS role_name, p.name AS privilege_name FROM role_privilege e JOIN tmp_cleanup_stale_privilege p ON p.uuid=e.privilege_id JOIN role r ON r.uuid=e.role_id LEFT JOIN tmp_cleanup_generated_role c ON c.uuid=e.role_id WHERE c.uuid IS NULL ORDER BY r.name, p.name;

CREATE TEMPORARY TABLE tmp_cleanup_keep_role LIKE `role`;

INSERT INTO tmp_cleanup_keep_role SELECT t.* FROM `role` t LEFT JOIN tmp_cleanup_generated_role c ON c.uuid=t.uuid WHERE c.uuid IS NULL;

CREATE TEMPORARY TABLE tmp_cleanup_keep_privilege LIKE `privilege`;

INSERT INTO tmp_cleanup_keep_privilege SELECT t.* FROM `privilege` t LEFT JOIN tmp_cleanup_stale_privilege c ON c.uuid=t.uuid WHERE c.uuid IS NULL;

CREATE TEMPORARY TABLE tmp_cleanup_keep_access_rule LIKE `access_rule`;

INSERT INTO tmp_cleanup_keep_access_rule SELECT t.* FROM `access_rule` t LEFT JOIN tmp_cleanup_v2_rule c ON c.uuid=t.uuid WHERE c.uuid IS NULL;

CREATE TEMPORARY TABLE tmp_cleanup_keep_user_role LIKE `user_role`;

INSERT INTO tmp_cleanup_keep_user_role SELECT e.* FROM `user_role` e WHERE NOT EXISTS (SELECT 1 FROM tmp_cleanup_generated_role c WHERE c.uuid=e.role_id);

SET @cleanup_expected_user_role = (SELECT COUNT(*) FROM `user_role`) - (SELECT COUNT(*) FROM tmp_cleanup_keep_user_role);

CREATE TEMPORARY TABLE tmp_cleanup_keep_role_privilege LIKE `role_privilege`;

INSERT INTO tmp_cleanup_keep_role_privilege SELECT e.* FROM `role_privilege` e WHERE NOT EXISTS (SELECT 1 FROM tmp_cleanup_generated_role c WHERE c.uuid=e.`role_id`) AND NOT EXISTS (SELECT 1 FROM tmp_cleanup_stale_privilege d WHERE d.uuid=e.`privilege_id`);

SET @cleanup_expected_role_privilege = (SELECT COUNT(*) FROM `role_privilege`) - (SELECT COUNT(*) FROM tmp_cleanup_keep_role_privilege);

CREATE TEMPORARY TABLE tmp_cleanup_keep_accessRule_privilege LIKE `accessRule_privilege`;

INSERT INTO tmp_cleanup_keep_accessRule_privilege SELECT e.* FROM `accessRule_privilege` e WHERE NOT EXISTS (SELECT 1 FROM tmp_cleanup_stale_privilege c WHERE c.uuid=e.`privilege_id`) AND NOT EXISTS (SELECT 1 FROM tmp_cleanup_v2_rule d WHERE d.uuid=e.`accessRule_id`);

SET @cleanup_expected_accessRule_privilege = (SELECT COUNT(*) FROM `accessRule_privilege`) - (SELECT COUNT(*) FROM tmp_cleanup_keep_accessRule_privilege);

CREATE TEMPORARY TABLE tmp_cleanup_keep_accessRule_gate LIKE `accessRule_gate`;

INSERT INTO tmp_cleanup_keep_accessRule_gate SELECT e.* FROM `accessRule_gate` e WHERE EXISTS (SELECT 1 FROM tmp_cleanup_accessRule_gate_scope s WHERE s.accessRule_id=e.accessRule_id AND s.`gate_id`=e.`gate_id` AND s.candidates=0);

SET @cleanup_expected_accessRule_gate = (SELECT COUNT(*) FROM `accessRule_gate`) - (SELECT COUNT(*) FROM tmp_cleanup_keep_accessRule_gate);

CREATE TEMPORARY TABLE tmp_cleanup_keep_accessRule_subRule LIKE `accessRule_subRule`;

INSERT INTO tmp_cleanup_keep_accessRule_subRule SELECT e.* FROM `accessRule_subRule` e WHERE EXISTS (SELECT 1 FROM tmp_cleanup_accessRule_subRule_scope s WHERE s.accessRule_id=e.accessRule_id AND s.`subRule_id`=e.`subRule_id` AND s.candidates=0);

SET @cleanup_expected_accessRule_subRule = (SELECT COUNT(*) FROM `accessRule_subRule`) - (SELECT COUNT(*) FROM tmp_cleanup_keep_accessRule_subRule);

SET @cleanup_expected_role=(SELECT COUNT(*) FROM tmp_cleanup_generated_role);

SET @cleanup_expected_privilege=(SELECT COUNT(*) FROM tmp_cleanup_stale_privilege);

SET @cleanup_expected_access_rule=(SELECT COUNT(*) FROM tmp_cleanup_v2_rule);

SET @cleanup_expected_parent_updates=0;

SELECT 'stale_privilege' AS candidate_class,COUNT(*) AS row_count FROM tmp_cleanup_stale_privilege;

SELECT 'stale_privilege' AS candidate_class,HEX(uuid) AS uuid_hex FROM tmp_cleanup_stale_privilege ORDER BY uuid;

SELECT 'generated_role' AS candidate_class,COUNT(*) AS row_count FROM tmp_cleanup_generated_role;

SELECT 'generated_role' AS candidate_class,HEX(uuid) AS uuid_hex FROM tmp_cleanup_generated_role ORDER BY uuid;

SELECT 'v2_rule' AS candidate_class,COUNT(*) AS row_count FROM tmp_cleanup_v2_rule;

SELECT 'v2_rule' AS candidate_class,HEX(uuid) AS uuid_hex FROM tmp_cleanup_v2_rule ORDER BY uuid;

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'no_retained_privilege_emptied_of_rules', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_keep_privilege k WHERE EXISTS (SELECT 1 FROM `accessRule_privilege` e WHERE e.`privilege_id`=k.uuid) AND NOT EXISTS (SELECT 1 FROM tmp_cleanup_keep_accessRule_privilege j WHERE j.`privilege_id`=k.uuid))),1,0);

SELECT 'PREFLIGHT_PASSED' AS status;

DELETE ur
FROM user_role ur
JOIN tmp_cleanup_generated_role cr ON cr.uuid = ur.role_id;
SET @deleted_user_role = ROW_COUNT();
SELECT 'cleanup_row_count' AS event, 'user_role' AS relation_name, @deleted_user_role AS row_count;

DELETE rp
FROM role_privilege rp
LEFT JOIN tmp_cleanup_generated_role cr ON cr.uuid = rp.role_id
LEFT JOIN tmp_cleanup_stale_privilege cp ON cp.uuid = rp.privilege_id
WHERE cr.uuid IS NOT NULL OR cp.uuid IS NOT NULL;
SET @deleted_role_privilege = ROW_COUNT();
SELECT 'cleanup_row_count' AS event, 'role_privilege' AS relation_name, @deleted_role_privilege AS row_count;

DELETE arp
FROM accessRule_privilege arp
LEFT JOIN tmp_cleanup_stale_privilege cp ON cp.uuid = arp.privilege_id
LEFT JOIN tmp_cleanup_v2_rule ca ON ca.uuid = arp.accessRule_id
WHERE cp.uuid IS NOT NULL OR ca.uuid IS NOT NULL;
SET @deleted_access_rule_privilege = ROW_COUNT();
SELECT 'cleanup_row_count' AS event, 'accessRule_privilege' AS relation_name, @deleted_access_rule_privilege AS row_count;

DELETE e FROM `accessRule_gate` e JOIN tmp_cleanup_v2_rule c ON c.uuid=e.accessRule_id;
SET @deleted_access_rule_gate=ROW_COUNT();
DELETE e FROM `accessRule_gate` e JOIN tmp_cleanup_v2_rule c ON c.uuid=e.`gate_id`;
SET @deleted_access_rule_gate=@deleted_access_rule_gate+ROW_COUNT();
SELECT 'cleanup_row_count' AS event, 'accessRule_gate' AS relation_name, @deleted_access_rule_gate AS row_count;

DELETE e FROM `accessRule_subRule` e JOIN tmp_cleanup_v2_rule c ON c.uuid=e.accessRule_id;
SET @deleted_access_rule_subrule=ROW_COUNT();
DELETE e FROM `accessRule_subRule` e JOIN tmp_cleanup_v2_rule c ON c.uuid=e.`subRule_id`;
SET @deleted_access_rule_subrule=@deleted_access_rule_subrule+ROW_COUNT();
SELECT 'cleanup_row_count' AS event, 'accessRule_subRule' AS relation_name, @deleted_access_rule_subrule AS row_count;

UPDATE access_rule child
JOIN tmp_cleanup_v2_rule parent_rule ON parent_rule.uuid = child.subAccessRuleParent_uuid
SET child.subAccessRuleParent_uuid = NULL;
SET @updated_access_rule_parent = ROW_COUNT();
SELECT 'cleanup_row_count' AS event, 'access_rule.subAccessRuleParent_uuid' AS relation_name, @updated_access_rule_parent AS row_count;

DELETE ar
FROM access_rule ar
JOIN tmp_cleanup_v2_rule ca ON ca.uuid = ar.uuid;
SET @deleted_access_rule = ROW_COUNT();
SELECT 'cleanup_row_count' AS event, 'access_rule' AS relation_name, @deleted_access_rule AS row_count;

DELETE p
FROM privilege p
JOIN tmp_cleanup_stale_privilege cp ON cp.uuid = p.uuid;
SET @deleted_privilege = ROW_COUNT();
SELECT 'cleanup_row_count' AS event, 'privilege' AS relation_name, @deleted_privilege AS row_count;

DELETE r
FROM `role` r
JOIN tmp_cleanup_generated_role cr ON cr.uuid = r.uuid;
SET @deleted_role = ROW_COUNT();
SELECT 'cleanup_row_count' AS event, 'role' AS relation_name, @deleted_role AS row_count;

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'deleted_role_count', IF((@deleted_role = @cleanup_expected_role),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'deleted_privilege_count', IF((@deleted_privilege = @cleanup_expected_privilege),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'deleted_access_rule_count', IF((@deleted_access_rule = @cleanup_expected_access_rule),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'deleted_user_role_count', IF((@deleted_user_role = @cleanup_expected_user_role),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'deleted_role_privilege_count', IF((@deleted_role_privilege = @cleanup_expected_role_privilege),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'deleted_accessRule_privilege_count', IF((@deleted_access_rule_privilege = @cleanup_expected_accessRule_privilege),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'deleted_accessRule_gate_count', IF((@deleted_access_rule_gate = @cleanup_expected_accessRule_gate),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'deleted_accessRule_subRule_count', IF((@deleted_access_rule_subrule = @cleanup_expected_accessRule_subRule),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'parent_update_count', IF((@updated_access_rule_parent=@cleanup_expected_parent_updates),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'role_retained_row_count', IF(((SELECT COUNT(*) FROM `role`)=(SELECT COUNT(*) FROM tmp_cleanup_keep_role)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'role_retained_rows_unchanged', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_keep_role k LEFT JOIN `role` t ON t.uuid=k.uuid WHERE t.uuid IS NULL OR NOT (CAST(t.`uuid` AS BINARY)<=>CAST(k.`uuid` AS BINARY) AND CAST(t.`name` AS BINARY)<=>CAST(k.`name` AS BINARY) AND CAST(t.`description` AS BINARY)<=>CAST(k.`description` AS BINARY)))),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'privilege_retained_row_count', IF(((SELECT COUNT(*) FROM `privilege`)=(SELECT COUNT(*) FROM tmp_cleanup_keep_privilege)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'privilege_retained_rows_unchanged', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_keep_privilege k LEFT JOIN `privilege` t ON t.uuid=k.uuid WHERE t.uuid IS NULL OR NOT (CAST(t.`uuid` AS BINARY)<=>CAST(k.`uuid` AS BINARY) AND CAST(t.`name` AS BINARY)<=>CAST(k.`name` AS BINARY) AND CAST(t.`description` AS BINARY)<=>CAST(k.`description` AS BINARY) AND CAST(t.`application_id` AS BINARY)<=>CAST(k.`application_id` AS BINARY) AND CAST(t.`queryTemplate` AS BINARY)<=>CAST(k.`queryTemplate` AS BINARY) AND CAST(t.`queryScope` AS BINARY)<=>CAST(k.`queryScope` AS BINARY)))),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'access_rule_retained_row_count', IF(((SELECT COUNT(*) FROM `access_rule`)=(SELECT COUNT(*) FROM tmp_cleanup_keep_access_rule)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'access_rule_retained_rows_unchanged', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_keep_access_rule k LEFT JOIN `access_rule` t ON t.uuid=k.uuid WHERE t.uuid IS NULL OR NOT (CAST(t.`uuid` AS BINARY)<=>CAST(k.`uuid` AS BINARY) AND CAST(t.`name` AS BINARY)<=>CAST(k.`name` AS BINARY) AND CAST(t.`description` AS BINARY)<=>CAST(k.`description` AS BINARY) AND CAST(t.`rule` AS BINARY)<=>CAST(k.`rule` AS BINARY) AND CAST(t.`type` AS BINARY)<=>CAST(k.`type` AS BINARY) AND CAST(t.`value` AS BINARY)<=>CAST(k.`value` AS BINARY) AND CAST(t.`checkMapKeyOnly` AS BINARY)<=>CAST(k.`checkMapKeyOnly` AS BINARY) AND CAST(t.`checkMapNode` AS BINARY)<=>CAST(k.`checkMapNode` AS BINARY) AND CAST(t.`subAccessRuleParent_uuid` AS BINARY)<=>CAST(k.`subAccessRuleParent_uuid` AS BINARY) AND CAST(t.`isGateAnyRelation` AS BINARY)<=>CAST(k.`isGateAnyRelation` AS BINARY) AND CAST(t.`isEvaluateOnlyByGates` AS BINARY)<=>CAST(k.`isEvaluateOnlyByGates` AS BINARY)))),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'user_role_retained_row_count', IF(((SELECT COUNT(*) FROM `user_role`)=(SELECT COUNT(*) FROM tmp_cleanup_keep_user_role)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'user_role_retained_rows_unchanged', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_keep_user_role k LEFT JOIN `user_role` t ON t.`user_id`=k.`user_id` AND t.`role_id`=k.`role_id` WHERE t.`user_id` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'role_privilege_retained_row_count', IF(((SELECT COUNT(*) FROM `role_privilege`)=(SELECT COUNT(*) FROM tmp_cleanup_keep_role_privilege)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'role_privilege_retained_rows_unchanged', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_keep_role_privilege k LEFT JOIN `role_privilege` t ON t.`role_id`=k.`role_id` AND t.`privilege_id`=k.`privilege_id` WHERE t.`role_id` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'accessRule_privilege_retained_row_count', IF(((SELECT COUNT(*) FROM `accessRule_privilege`)=(SELECT COUNT(*) FROM tmp_cleanup_keep_accessRule_privilege)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'accessRule_privilege_retained_rows_unchanged', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_keep_accessRule_privilege k LEFT JOIN `accessRule_privilege` t ON t.`privilege_id`=k.`privilege_id` AND t.`accessRule_id`=k.`accessRule_id` WHERE t.`privilege_id` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'accessRule_gate_retained_row_count', IF(((SELECT COUNT(*) FROM `accessRule_gate`)=(SELECT COUNT(*) FROM tmp_cleanup_keep_accessRule_gate)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'accessRule_gate_retained_rows_unchanged', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_keep_accessRule_gate k LEFT JOIN `accessRule_gate` t ON t.`accessRule_id`=k.`accessRule_id` AND t.`gate_id`=k.`gate_id` WHERE t.`accessRule_id` IS NULL)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'accessRule_subRule_retained_row_count', IF(((SELECT COUNT(*) FROM `accessRule_subRule`)=(SELECT COUNT(*) FROM tmp_cleanup_keep_accessRule_subRule)),1,0);

INSERT INTO tmp_cleanup_assert (check_name, passed) SELECT 'accessRule_subRule_retained_rows_unchanged', IF((NOT EXISTS (SELECT 1 FROM tmp_cleanup_keep_accessRule_subRule k LEFT JOIN `accessRule_subRule` t ON t.`accessRule_id`=k.`accessRule_id` AND t.`subRule_id`=k.`subRule_id` WHERE t.`accessRule_id` IS NULL)),1,0);

SELECT 'CLEANUP_DML_VALIDATED' AS status;
COMMIT;
SET SESSION transaction_isolation=@cleanup_original_isolation;

DROP TEMPORARY TABLE tmp_cleanup_keep_accessRule_subRule;
DROP TEMPORARY TABLE tmp_cleanup_keep_accessRule_gate;
DROP TEMPORARY TABLE tmp_cleanup_keep_accessRule_privilege;
DROP TEMPORARY TABLE tmp_cleanup_keep_role_privilege;
DROP TEMPORARY TABLE tmp_cleanup_keep_user_role;
DROP TEMPORARY TABLE tmp_cleanup_keep_access_rule;
DROP TEMPORARY TABLE tmp_cleanup_keep_privilege;
DROP TEMPORARY TABLE tmp_cleanup_keep_role;
DROP TEMPORARY TABLE tmp_cleanup_accessRule_subRule_scope;
DROP TEMPORARY TABLE tmp_cleanup_accessRule_gate_scope;
DROP TEMPORARY TABLE tmp_cleanup_rule_classification;
DROP TEMPORARY TABLE tmp_cleanup_classification_blocker;
DROP TEMPORARY TABLE tmp_cleanup_generated_role;
DROP TEMPORARY TABLE tmp_cleanup_role_classification;
DROP TEMPORARY TABLE tmp_cleanup_stale_privilege;
DROP TEMPORARY TABLE tmp_cleanup_privilege_shape;
DROP TEMPORARY TABLE tmp_cleanup_v2_rule;
DROP TEMPORARY TABLE tmp_cleanup_topmed_parent;
DROP TEMPORARY TABLE tmp_cleanup_restricted_suffix;
DROP TEMPORARY TABLE tmp_cleanup_phenotype_suffix;
DROP TEMPORARY TABLE tmp_cleanup_consent_shape;
DROP TEMPORARY TABLE tmp_cleanup_rule_shape;
DROP TEMPORARY TABLE tmp_cleanup_rule_signature;
DROP TEMPORARY TABLE tmp_cleanup_protected_rule;
DROP TEMPORARY TABLE tmp_cleanup_protected_privilege;
DROP TEMPORARY TABLE tmp_cleanup_protected_role;
DROP TEMPORARY TABLE tmp_cleanup_baseline_rule;
DROP TEMPORARY TABLE tmp_cleanup_baseline_privilege;
DROP TEMPORARY TABLE tmp_cleanup_baseline_role;
DROP TEMPORARY TABLE tmp_cleanup_actual_fk;
DROP TEMPORARY TABLE tmp_cleanup_required_fk;
DROP TEMPORARY TABLE tmp_cleanup_required_column;
DROP TEMPORARY TABLE tmp_cleanup_required_table;
DROP TEMPORARY TABLE tmp_cleanup_assert;
