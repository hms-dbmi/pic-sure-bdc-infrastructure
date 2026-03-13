INSERT INTO connection
(uuid, label, id, subprefix, requiredFields)
VALUES (
  UNHEX(REPLACE('9770edc4-1533-4796-9005-5cfb77c0f28d', '-', '')),
  'RAS',
  'ras',
  'okta-ras|',
  '[{"label":"Email", "id":"email"}]'
) AS new_vals
ON DUPLICATE KEY UPDATE
    label           = new_vals.label,
    id              = new_vals.id,
    subprefix       = new_vals.subprefix,
    requiredFields  = new_vals.requiredFields;