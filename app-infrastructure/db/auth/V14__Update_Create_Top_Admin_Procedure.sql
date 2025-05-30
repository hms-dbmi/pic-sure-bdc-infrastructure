--
-- Create Super Admin and admin roles and privileges with upsert logic
--

-- Get existing privilege UUIDs from database
SELECT uuid INTO @superAdminPrivilegeUUID FROM privilege WHERE name = 'SUPER_ADMIN';
SELECT uuid INTO @adminPrivilegeUUID FROM privilege WHERE name = 'ADMIN';

-- Verify privileges exist, if not throw error
IF @superAdminPrivilegeUUID IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'SUPER_ADMIN privilege not found in database';
END IF;

IF @adminPrivilegeUUID IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ADMIN privilege not found in database';
END IF;

-- Get existing role UUIDs from database or create them if they don't exist
SELECT uuid INTO @superAdminRoleUUID FROM role WHERE name = 'PIC-SURE Top Admin';
SELECT uuid INTO @adminRoleUUID FROM role WHERE name = 'Admin';

-- Create roles if they don't exist
IF @superAdminRoleUUID IS NULL THEN
    SET @superAdminRoleUUID = UNHEX(REPLACE(UUID(), '-', ''));
    INSERT INTO role (uuid, name, description) VALUES
        (@superAdminRoleUUID,'PIC-SURE Top Admin','PIC-SURE Auth Micro App Top admin including Admin and super Admin, can manage roles and privileges directly');
END IF;

IF @adminRoleUUID IS NULL THEN
    SET @adminRoleUUID = UNHEX(REPLACE(UUID(), '-', ''));
    INSERT INTO role (uuid, name, description) VALUES
        (@adminRoleUUID,'Admin','Normal admin users, can manage other users including assignment of roles and privileges');
END IF;

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
