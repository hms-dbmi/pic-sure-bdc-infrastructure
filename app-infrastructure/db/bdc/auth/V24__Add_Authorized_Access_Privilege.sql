-- AUTHORIZED_ACCESS is the privilege the UI reads to show the authorized data routes. It has no
-- access rule, so it grants nothing; MANAGED_PRIV_AUTH_ACCESS on this role is the grant.

use auth;

SET @uuidAuthorizedAccessPriv = REPLACE(UUID(), '-', '');
INSERT INTO privilege (uuid, name, description, application_id, queryScope)
VALUES (unhex(@uuidAuthorizedAccessPriv),
        'AUTHORIZED_ACCESS',
        'Privilege the UI reads to show the authorized data routes; grants nothing on its own',
        (SELECT uuid FROM application WHERE name = 'PICSURE'),
        '[]');

INSERT INTO role_privilege (role_id, privilege_id)
VALUES ((SELECT uuid FROM role WHERE name = 'MANUAL_ROLE_AUTH_ACCESS'),
        unhex(@uuidAuthorizedAccessPriv));
