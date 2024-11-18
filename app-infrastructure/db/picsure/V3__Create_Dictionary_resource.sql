use picsure;

SET @dictResourceUUID = unhex(REPLACE(UUID(), '-', ''));

INSERT INTO `resource`
(uuid, targetURL, resourceRSPath, description, name, token, hidden, metadata)
VALUES
    (@dictResourceUUID, NULL, 'http://dictionary-api/',
     'Dictionary API', 'dictionary-api', NULL, TRUE, NULL);