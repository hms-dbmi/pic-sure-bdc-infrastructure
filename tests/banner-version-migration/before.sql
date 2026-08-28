ALTER TABLE banner_occurrence MODIFY updated_at DATETIME(6) NULL;

INSERT INTO banner_occurrence (
    uuid, status, html_content, title, appearance, icon, dismissible, audience, placement, page_targets,
    start_at, end_at, priority, presentation_hash, created_at, created_by, updated_at, updated_by, published_at, published_by
) VALUES (
    UUID_TO_BIN('00000000-0000-0000-0000-000000000001'), 'PUBLISHED', '<p>Publication | time wins</p>', 'Published metadata',
    'WARNING', 'WARNING', FALSE, 'SIGNED_IN', 'SITE_TOP', JSON_ARRAY(JSON_OBJECT('kind', 'EXACT', 'path', '/admin|status')),
    '2026-08-27 11:30:00.000000', '2026-08-28 12:00:00.000000', 1, REPEAT('a', 64), '2026-08-27 10:00:00.000000', 'creator',
    '2026-08-27 13:00:00.000000', 'updater', '2026-08-27 12:00:00.000000', 'publisher'
), (
    UUID_TO_BIN('00000000-0000-0000-0000-000000000002'), 'PUBLISHED', '<p>Updated time fallback</p>', 'Updated metadata',
    'PRIMARY', 'INFORMATION', TRUE, 'EVERYONE', 'SITE_TOP', JSON_ARRAY(JSON_OBJECT('kind', 'ALL')),
    '2026-08-27 13:00:00.000000', '2026-08-29 13:00:00.000000', 2, REPEAT('b', 64), '2026-08-27 10:00:00.000000', 'creator',
    '2026-08-27 13:00:00.000000', 'updater', NULL, NULL
), (
    UUID_TO_BIN('00000000-0000-0000-0000-000000000003'), 'PUBLISHED', '<p>Created time fallback</p>', 'Created metadata',
    'ERROR', 'ERROR', FALSE, 'SIGNED_OUT', 'SITE_TOP', JSON_ARRAY(JSON_OBJECT('kind', 'EXACT', 'path', '/created')),
    '2026-08-27 14:00:00.000000', '2026-08-30 14:00:00.000000', 3, REPEAT('c', 64), '2026-08-27 09:00:00.000000', 'creator',
    NULL, 'updater', NULL, ''
), (
    UUID_TO_BIN('00000000-0000-0000-0000-000000000004'), 'SAVED', '<p>Saved</p>', 'Saved',
    'PRIMARY', 'NONE', TRUE, 'EVERYONE', 'SITE_TOP', JSON_ARRAY(JSON_OBJECT('kind', 'ALL')),
    '2026-08-27 15:00:00.000000', NULL, 4, REPEAT('d', 64), '2026-08-27 08:00:00.000000', 'creator',
    '2026-08-27 15:00:00.000000', 'updater', '2026-08-27 14:00:00.000000', 'publisher'
);
