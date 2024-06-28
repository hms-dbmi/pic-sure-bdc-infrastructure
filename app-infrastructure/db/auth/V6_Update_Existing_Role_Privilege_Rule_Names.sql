# We have migrated our naming convention away from "FENCE_" to a more generalized "MANAGED_".
-- Update roles table
UPDATE roles
SET name = REPLACE(name, 'FENCE', 'MANAGED')
WHERE name LIKE 'FENCE%';

UPDATE roles
SET description = REPLACE(description, 'FENCE', 'MANAGED')
WHERE description LIKE '%FENCE%';

-- Update privileges table
UPDATE privileges
SET name = REPLACE(name, 'PRIV_FENCE', 'PRIV_MANAGED')
WHERE name LIKE 'PRIV_FENCE%';

UPDATE privileges
SET description = REPLACE(description, 'FENCE', 'MANAGED')
WHERE description LIKE '%FENCE%';

-- Update access rules table
UPDATE access_rules
SET name = REPLACE(name, 'FENCE', 'MANAGED')
WHERE name LIKE 'FENCE%';

UPDATE access_rules
SET description = REPLACE(description, 'FENCE', 'MANAGED')
WHERE description LIKE '%FENCE%';
