INSERT INTO auth.role (uuid, name, description)
VALUES (
    UUID_TO_BIN('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
    'Synthetic preserved role',
    'Synthetic deployment migration proof row'
);

INSERT INTO picsure.user (uuid, roles, subject, userId)
VALUES (
    UUID_TO_BIN('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
    'SYNTHETIC',
    'synthetic-banner-proof',
    'preserve-me'
);
