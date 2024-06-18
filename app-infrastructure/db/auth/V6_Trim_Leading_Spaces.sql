-- Update rows to remove leading spaces
UPDATE access_rule SET rule = LTRIM(rule) WHERE rule LIKE ' %';