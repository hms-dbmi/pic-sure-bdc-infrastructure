-- Point the legacy dictionary UUID to the new Dictionary-API
-- Eventually we will complete remove this resource from the dictionary.
update resource SET resourceRSPath = 'http://dictionary-api/' WHERE UUID = unhex(replace('36363664-6231-6134-2d38-6538652d3131', '-', ''));