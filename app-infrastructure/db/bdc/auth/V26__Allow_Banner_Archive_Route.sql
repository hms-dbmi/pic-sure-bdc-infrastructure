-- Rollout requirement: PSAMA caches detached access rules per user and application in `mergedRulesCache` and
-- `preProcessedAccessRules`, so this in-place UPDATE is not visible to already-cached sessions. Restart the PSAMA
-- instances or evict both caches after this migration runs, or archive requests keep failing authorization.
USE auth;

UPDATE access_rule
SET value = '^/operations/banners(?:/?|/saved/?|/order/?|/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(?:/?|/publish/?|/disable/?|/archive/?))$',
    description = 'Allow the banner management privilege through explicit gateway operations routes'
WHERE name = 'AR_BANNER_MANAGEMENT_GATEWAY';
