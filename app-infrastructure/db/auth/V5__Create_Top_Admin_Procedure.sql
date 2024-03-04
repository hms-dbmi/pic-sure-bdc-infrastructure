--
-- Create Super Admin and admin roles and privileges
--
SET @superAdminPrivilegeUUID = UNHEX('7044061AF65B425F86CE73A1BF7F4402');
SET @adminPrivilegeUUID = UNHEX('AD08212E096F414CBA8D1BAE09415DAB');

INSERT INTO privilege (uuid, description, name, application_id, queryTemplate, queryScope) VALUES
                                                                                               (@superAdminPrivilegeUUID,'PIC-SURE Auth super admin for managing roles/privileges/application/connections','SUPER_ADMIN',NULL,'[]',NULL),
                                                                                               (@adminPrivilegeUUID,'PIC-SURE Auth admin for managing users.','ADMIN',NULL,'[]',NULL);

SET @superAdminRoleUUID = UNHEX('002DC366B0D8420F998F885D0ED797FD');
SET @adminRoleUUID = UNHEX('8F885D0ED797FD002DC366B0D8420F99');

INSERT INTO role (uuid, name, description) VALUES
                                               (@superAdminRoleUUID,'PIC-SURE Top Admin','PIC-SURE Auth Micro App Top admin including Admin and super Admin, can manage roles and privileges directly'),
                                               (@adminRoleUUID,'Admin','Normal admin users, can manage other users including assignment of roles and privileges');

INSERT INTO role_privilege (role_id, privilege_id) VALUES
                                                       (@superAdminRoleUUID,@superAdminPrivilegeUUID),
                                                       (@superAdminRoleUUID,@adminPrivilegeUUID),
                                                       (@adminRoleUUID,@adminPrivilegeUUID);

DROP PROCEDURE IF EXISTS CreateSuperUser;
delimiter //
CREATE PROCEDURE CreateSuperUser (IN user_email varchar(255), IN connection_id varchar(255))
BEGIN
SELECT @connectionUUID := uuid FROM auth.connection WHERE id = connection_id;
SELECT @userUUID := uuid FROM auth.user WHERE email = user_email AND connectionId = @connectionUUID;
SELECT @saUUID := uuid FROM auth.role WHERE name = 'PIC-SURE Top Admin';
SELECT @adminUUID := uuid FROM auth.role WHERE name = 'Admin';
IF @userUUID IS NULL THEN
    SET @userUUID = UNHEX(REPLACE(UUID(), '-', ''));
INSERT INTO auth.user (uuid, general_metadata, acceptedTOS, connectionId, email, matched, subject, is_active, long_term_token, isGateAnyRelation)
VALUES (@userUUID, null, (SELECT CURRENT_TIMESTAMP), @connectionUUID, user_email, 0, null, 1, null, 1);
INSERT INTO auth.user_role (user_id, role_id) VALUES (@userUUID,@saUUID);
INSERT INTO auth.user_role (user_id, role_id) VALUES (@userUUID,@adminUUID);
END IF;
END//
delimiter ;