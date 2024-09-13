# Simple rule to allow routing to the dictionary
use auth;

SET @allowDictionaryRequests = unhex(REPLACE(UUID(),'-',''));
-- Access rule for allowing requests to the uploader via proxy
INSERT
INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)    VALUES (
                @allowDictionaryRequests, 'ALLOW_DICTIONARY_REQUESTS', 'Permit requests to dictionary endpoints',
                '$.[\'Target Service\']', 6, '/proxy/dictionary-api/facets/',
             0x00, 0x00, NULL, 0x00, 0x00
            );
-- Add that access rule to the PIC_SURE_ANY_QUERY privilege
SET @uuidPriv = (SELECT uuid FROM privilege WHERE name = 'MANAGED_PRIV_DICTIONARY'); -- FENCE_ was previously replaced with MANAGED_
INSERT
INTO accessRule_privilege (privilege_id, accessRule_id)
VALUES
    (@uuidPriv, @allowDictionaryRequests);