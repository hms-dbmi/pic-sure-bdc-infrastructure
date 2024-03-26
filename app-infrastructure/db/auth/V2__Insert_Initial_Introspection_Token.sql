-- Need to upsert token incase it already exists
INSERT INTO `application`
VALUES (0x8B5722C962FD48D6B0BF4F67E53EFB2B, 'PIC-SURE multiple data access API', 0x01, 'PICSURE',
        '${picsure_token_introspection_token}', '/picsureui') ON DUPLICATE KEY
UPDATE `token` =
VALUES (`token`);