SET @allowLoggingRequests = unhex(REPLACE(UUID(),'-',''));
INSERT INTO auth.access_rule (
      uuid, name, description, rule, type, value, checkMapKeyOnly, checkMapNode,
      subAccessRuleParent_uuid, isGateAnyRelation, isEvaluateOnlyByGates
  ) VALUES (
      @allowLoggingRequests, 'AR_LOGGING_REQUESTS', 'Permit requests to logging endpoints',
      '$.[\'Target Service\']', 11, '^/proxy/pic-sure-logging/.*$',
      0x00, 0x00, NULL, 0x00, 0x00
  );
