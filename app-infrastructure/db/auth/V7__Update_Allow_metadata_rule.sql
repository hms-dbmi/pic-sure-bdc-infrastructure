-- Update the access rule for metadata access to use the 'Target Service' field instead of 'path'
UPDATE access_rule
SET rule = '$.["Target Service"]', type = 6, checkMapKeyOnly = 0,
    checkMapNode = 0,isEvaluateOnlyByGates = 0, isGateAnyRelation = 0
WHERE name = 'ALLOW_METADATA_ACCESS';