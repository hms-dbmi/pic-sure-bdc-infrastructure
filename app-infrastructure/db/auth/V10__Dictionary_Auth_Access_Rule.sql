# Simple rule to allow routing to the dictionary
use auth2;

SET @allowDictionaryRequests = unhex(REPLACE(UUID(),'-',''));
-- Access rule for allowing requests to the uploader via proxy
INSERT
INTO access_rule (
    uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
    subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
)    VALUES (
                @allowDictionaryRequests, 'AR_DICTIONARY_REQUESTS', 'Permit requests to dictionary endpoints',
                '$.[\'Target Service\']', 11, '^/proxy/dictionary-api/.*$',
             0x00, 0x00, NULL, 0x00, 0x00
            );