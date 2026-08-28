DROP DATABASE IF EXISTS auth;
CREATE DATABASE auth;
USE auth;

CREATE TABLE application (
    uuid BINARY(16) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE role (
    uuid BINARY(16) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE access_rule (
    uuid BINARY(16) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description VARCHAR(2000),
    rule VARCHAR(255),
    type INT,
    value VARCHAR(1000),
    checkMapKeyOnly BIT NOT NULL,
    checkMapNode BIT NOT NULL,
    subAccessRuleParent_uuid BINARY(16),
    isGateAnyRelation BIT NOT NULL,
    isEvaluateOnlyByGates BIT NOT NULL
);

CREATE TABLE privilege (
    uuid BINARY(16) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description VARCHAR(2000),
    application_id BINARY(16),
    queryScope VARCHAR(1000)
);

CREATE TABLE accessRule_privilege (
    privilege_id BINARY(16) NOT NULL,
    accessRule_id BINARY(16) NOT NULL,
    PRIMARY KEY (privilege_id, accessRule_id)
);

CREATE TABLE role_privilege (
    role_id BINARY(16) NOT NULL,
    privilege_id BINARY(16) NOT NULL,
    PRIMARY KEY (role_id, privilege_id)
);

INSERT INTO application (uuid, name)
VALUES (UNHEX(REPLACE(UUID(), '-', '')), 'PICSURE');

INSERT INTO role (uuid, name)
VALUES
    (UNHEX(REPLACE(UUID(), '-', '')), 'Admin'),
    (UNHEX(REPLACE(UUID(), '-', '')), 'PIC-SURE Top Admin'),
    (UNHEX(REPLACE(UUID(), '-', '')), 'PIC-SURE User');
