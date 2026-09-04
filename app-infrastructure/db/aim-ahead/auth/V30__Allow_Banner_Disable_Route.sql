USE auth;

UPDATE access_rule
SET value = '^/operations/banners(?:/?|/saved/?|/order/?|/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(?:/?|/publish/?|/disable/?))$',
    description = 'Allow the banner management privilege through explicit gateway operations routes'
WHERE name = 'AR_BANNER_MANAGEMENT_GATEWAY';
