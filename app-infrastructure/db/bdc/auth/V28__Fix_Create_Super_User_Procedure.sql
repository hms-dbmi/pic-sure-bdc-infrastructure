-- Recreate CreateSuperUser, the procedure behind the Create Top Admin Jenkins job.
--
-- V5 granted 'PIC-SURE Top Admin' and 'Admin' only in the branch that inserts a new user, so
-- calling it for someone who had already logged in changed nothing and reported no error. It
-- also inserted the user with a NULL connectionId when connection_id matched no connection; the
-- (email, connectionId) unique key admits repeated NULLs, so every retry added another admin
-- that no login would ever resolve to.
--
-- This version refuses an unknown connection, finds or creates the user, and then grants both
-- roles whether or not the user already existed. Grants are idempotent, so the job can be rerun.
--
-- The parameters use the columns' utf8mb3_bin collation so the email and connection id match
-- exactly as PSAMA's login lookup does. Under the server default collation 'Ras' matched 'ras'
-- here while the login lookup would not, leaving the grant on a user nobody logs in as.

use auth;

DROP PROCEDURE IF EXISTS CreateSuperUser;

DELIMITER //
CREATE PROCEDURE CreateSuperUser(
    IN user_email varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin,
    IN connection_id varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin
)
BEGIN
    DECLARE v_connection_uuid binary(16);
    DECLARE v_user_uuid binary(16);
    DECLARE v_message varchar(255);

    SET v_connection_uuid = (SELECT uuid FROM auth.connection WHERE id = connection_id);
    IF v_connection_uuid IS NULL THEN
        SET v_message = CONCAT('CreateSuperUser: no connection with id ''', connection_id, '''');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_message;
    END IF;

    IF (SELECT COUNT(DISTINCT name) FROM auth.role WHERE name IN ('PIC-SURE Top Admin', 'Admin')) <> 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CreateSuperUser: role ''PIC-SURE Top Admin'' or ''Admin'' is missing';
    END IF;

    SET v_user_uuid = (SELECT uuid FROM auth.user WHERE email = user_email AND connectionId = v_connection_uuid);
    IF v_user_uuid IS NULL THEN
        SET v_user_uuid = UNHEX(REPLACE(UUID(), '-', ''));
        INSERT INTO auth.user (uuid, general_metadata, acceptedTOS, connectionId, email, matched, subject, is_active,
                               long_term_token, isGateAnyRelation)
        VALUES (v_user_uuid, NULL, CURRENT_TIMESTAMP, v_connection_uuid, user_email, 0, NULL, 1, NULL, 1);
    END IF;

    INSERT INTO auth.user_role (user_id, role_id)
    SELECT v_user_uuid, r.uuid
    FROM auth.role r
    WHERE r.name IN ('PIC-SURE Top Admin', 'Admin')
      AND NOT EXISTS (SELECT 1 FROM auth.user_role ur WHERE ur.user_id = v_user_uuid AND ur.role_id = r.uuid);
END//
DELIMITER ;
