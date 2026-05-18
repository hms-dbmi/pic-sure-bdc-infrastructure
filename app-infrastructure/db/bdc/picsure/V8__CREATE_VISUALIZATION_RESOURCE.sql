INSERT INTO `resource`
    (uuid, targetURL, resourceRSPath, description, name, token, hidden, metadata)
VALUES
    (unhex(REPLACE('ca0ad4a9-130a-3a8a-ae00-e35b07f1108b', '-', '')), NULL,
     'http://visualization/', 'Visualization', 'visualization', NULL, TRUE, NULL)
ON DUPLICATE KEY UPDATE
    targetURL = VALUES(targetURL),
    resourceRSPath = VALUES(resourceRSPath),
    description = VALUES(description),
    name = VALUES(name),
    token = VALUES(token),
    hidden = VALUES(hidden),
    metadata = VALUES(metadata);
