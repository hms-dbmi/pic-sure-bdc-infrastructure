use auth;

UPDATE access_rule
SET value = '^/operations/banners(?:/?|/saved/?|/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(?:/?|/publish/?))$',
    description = 'Allow the banner management privilege through explicit gateway operations routes'
WHERE name = 'AR_BANNER_MANAGEMENT_GATEWAY'
  AND value = '^/operations/banners/?$';
