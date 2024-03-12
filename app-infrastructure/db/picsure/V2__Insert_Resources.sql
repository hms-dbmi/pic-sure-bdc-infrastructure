-- We only need one of the following resources because their DNS names are localhost, so it is not necessary to include the target_stack and env_private_dns_name variables in the URL.
INSERT INTO `resource`
VALUES (0xCA0AD4A9130A3A8AAE00E35B07F1108B, NULL,
        'http://localhost:8080/pic-sure-visualization-resource/pic-sure/visualization', 'Visualization',
        'visualization', NULL, false, NULL);
INSERT INTO `resource`
VALUES (0x70c837be5ffc11ebae930242ac130002, NULL,
        'http://localhost:8080/pic-sure-aggregate-resource/pic-sure/aggregate-data-sharing',
        'Open Access (aggregate) resource', 'open-hpds', NULL, ${include_open_hpds}, NULL);

-- For both Auth HPDS and the Dictionary, we need to include the target_stack and env_private_dns_name variables in the URL.
-- This requires two separate resources for each, one for the Auth HPDS and one for the Dictionary.
INSERT INTO `resource`
VALUES (unhex(REPLACE('02e23f52-f354-4e8b-992c-d37c8b9ba140', '-', '')), NULL,
        'http://auth-hpds.___target_stack___:8080/PIC-SURE/', 'Authorized Access HPDS resource', 'auth-hpds',
        NULL, ${include_auth_hpds}, NULL);

INSERT INTO `resource`
VALUES (unhex(REPLACE('36363664-6231-6134-2d38-6538652d3131', '-', '')), NULL,
        'http://dictionary.___target_stack___:8080/dictionary/pic-sure', 'Dictionary', 'dictionary', NULL, false,
        NULL);