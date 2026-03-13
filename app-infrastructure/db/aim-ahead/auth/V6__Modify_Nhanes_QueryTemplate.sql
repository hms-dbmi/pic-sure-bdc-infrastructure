-- This query template is replacing the current nhanes one, which is:
-- {"categoryFilters": {"\\_consents\\":["nhanes"]},"numericFilters":{},"requiredFields":[],"fields":[""],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}
-- The only difference is the fields key, which now an empty array, as the previous one was an array with an empty string.
UPDATE privilege
SET queryTemplate = '{"categoryFilters": {"\\\\_consents\\\\":["nhanes"]},"numericFilters":{},"requiredFields":[],"fields":[],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}'
WHERE name = "PRIV_FENCE_nhanes";
