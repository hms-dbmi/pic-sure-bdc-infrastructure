-- SET
-- @uuidGATE_QUERY = REPLACE(UUID(),'-','');
-- INSERT INTO access_rule
-- VALUES (unhex(@uuidGATE_QUERY),
--         'GATE_QUERY',
--         'triggers if user submits a query',
--         '$.[\'Target Service\']',
--         6,
--         '/query ',
--         0,
--         0,
--         NULL,
--         0,
--         0);

-- In order to include the GATE_QUERY it needs to contain AR_ in the name
UPDATE access_rule
SET name = 'AR_GATE_QUERY'
WHERE name = 'GATE_QUERY';