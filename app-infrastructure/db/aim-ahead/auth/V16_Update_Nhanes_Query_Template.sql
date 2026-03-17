UPDATE privilege
SET queryTemplate = '{"categoryFilters": {"\\\\_consents\\\\":["Nhanes"]},"numericFilters":{},"requiredFields":[],"fields":[],"variantInfoFilters":[{"categoryVariantInfoFilters":{},"numericVariantInfoFilters":{}}],"expectedResultType": "COUNT"}'
WHERE name = "PRIV_MANAGED_nhanes";

update privilege
SET queryScope = '["\\\\Nhanes\\\\","_"]'
where name = "PRIV_MANAGED_nhanes";


update access_rule set value = '\\Nhanes\\'
where value = '\\\\nhanes\\\\';

update access_rule set value = 'Nhanes'
where value = 'nhanes';