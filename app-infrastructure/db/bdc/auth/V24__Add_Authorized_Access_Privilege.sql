-- AUTHORIZED_ACCESS is the privilege the UI reads to show the authorized data routes. It has no
-- access rule, so it grants nothing; MANAGED_PRIV_AUTH_ACCESS on this role is the grant.
--
-- Both inserts are conditional. privilege.name is unique, so an AUTHORIZED_ACCESS row created by
-- hand ahead of this migration would otherwise fail the run with a duplicate key after the
-- migrations before it had already committed. Whichever row exists afterwards is the one the
-- role is bound to.

use auth;

INSERT INTO privilege (uuid, name, description, application_id, queryScope)
SELECT unhex(REPLACE(UUID(), '-', '')),
       'AUTHORIZED_ACCESS',
       'Privilege the UI reads to show the authorized data routes; grants nothing on its own',
       (SELECT uuid FROM application WHERE name = 'PICSURE'),
       '[]'
FROM dual
WHERE NOT EXISTS (SELECT 1 FROM privilege WHERE name = 'AUTHORIZED_ACCESS');

INSERT INTO role_privilege (role_id, privilege_id)
SELECT r.uuid, p.uuid
FROM role r
JOIN privilege p ON p.name = 'AUTHORIZED_ACCESS'
WHERE r.name = 'MANUAL_ROLE_AUTH_ACCESS'
  AND NOT EXISTS (SELECT 1
                  FROM role_privilege rp
                  WHERE rp.role_id = r.uuid AND rp.privilege_id = p.uuid);
