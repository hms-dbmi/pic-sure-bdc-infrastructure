--
-- Create Super Admin and admin roles and privileges with upsert logic
--

-- Set specific UUIDs for consistency across environments
SET @superAdminPrivilegeUUID = UNHEX('7044061AF65B425F86CE73A1BF7F4402');
SET @adminPrivilegeUUID = UNHEX('AD08212E096F414CBA8D1BAE09415DAB');

-- Insert privileges if they don't exist (using INSERT IGNORE)
INSERT IGNORE INTO privilege (uuid, description, name, application_id, queryTemplate, queryScope) VALUES
    (@superAdminPrivilegeUUID,'PIC-SURE Auth super admin for managing roles/privileges/application/connections','SUPER_ADMIN',NULL,'[]',NULL),
    (@adminPrivilegeUUID,'PIC-SURE Auth admin for managing users.','ADMIN',NULL,'[]',NULL);

-- Set specific role UUIDs for consistency
SET @superAdminRoleUUID = UNHEX('002DC366B0D8420F998F885D0ED797FD');
SET @adminRoleUUID = UNHEX('8F885D0ED797FD002DC366B0D8420F99');

-- Insert roles if they don't exist (using INSERT IGNORE)
INSERT IGNORE INTO role (uuid, name, description) VALUES
    (@superAdminRoleUUID,'PIC-SURE Top Admin','PIC-SURE Auth Micro App Top admin including Admin and super Admin, can manage roles and privileges directly'),
    (@adminRoleUUID,'Admin','Normal admin users, can manage other users including assignment of roles and privileges');

-- Insert role_privilege relationships if they don't exist
INSERT IGNORE INTO role_privilege (role_id, privilege_id) VALUES
    (@superAdminRoleUUID,@superAdminPrivilegeUUID),
    (@superAdminRoleUUID,@adminPrivilegeUUID),
    (@adminRoleUUID,@adminPrivilegeUUID);

-- Drop and recreate the procedure
DROP PROCEDURE IF EXISTS CreateSuperUser;

DELIMITER //
CREATE PROCEDURE CreateSuperUser (IN user_email VARCHAR(255), IN connection_id VARCHAR(255))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Get connection UUID
    SELECT uuid INTO @connectionUUID FROM auth.connection WHERE id = connection_id;
    
    -- Check if connection exists
    IF @connectionUUID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Connection not found';
    END IF;
    
    -- Get role UUIDs
    SELECT uuid INTO @saUUID FROM auth.role WHERE name = 'PIC-SURE Top Admin';
    SELECT uuid INTO @adminUUID FROM auth.role WHERE name = 'Admin';
    
    -- Check if user exists
    SELECT uuid INTO @userUUID FROM auth.user 
    WHERE email = user_email AND connectionId = @connectionUUID;
    
    IF @userUUID IS NULL THEN
        -- User doesn't exist, create new user
        SET @userUUID = UNHEX(REPLACE(UUID(), '-', ''));
        
        INSERT INTO auth.user (uuid, general_metadata, acceptedTOS, connectionId, email, matched, subject, is_active, long_term_token, isGateAnyRelation)
        VALUES (@userUUID, NULL, CURRENT_TIMESTAMP, @connectionUUID, user_email, 0, NULL, 1, NULL, 1);
        
        -- Assign roles to new user
        INSERT INTO auth.user_role (user_id, role_id) VALUES 
            (@userUUID, @saUUID),
            (@userUUID, @adminUUID);
            
        SELECT CONCAT('User created: ', user_email) AS result;
    ELSE
        -- User exists, update if needed and ensure roles are assigned
        UPDATE auth.user 
        SET is_active = 1,
            acceptedTOS = CURRENT_TIMESTAMP
        WHERE uuid = @userUUID;
        
        -- Ensure user has the required roles (use INSERT IGNORE to avoid duplicates)
        INSERT IGNORE INTO auth.user_role (user_id, role_id) VALUES 
            (@userUUID, @saUUID),
            (@userUUID, @adminUUID);
            
        SELECT CONCAT('User updated: ', user_email) AS result;
    END IF;
    
    COMMIT;
END//
DELIMITER ;
