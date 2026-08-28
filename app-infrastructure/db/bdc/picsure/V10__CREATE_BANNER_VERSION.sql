USE picsure;

CREATE TABLE banner_version
(
    uuid                 BINARY(16)   NOT NULL,
    banner_uuid          BINARY(16)   NOT NULL,
    version_number       INT          NOT NULL,
    html_content         TEXT         NOT NULL,
    title                VARCHAR(120) DEFAULT NULL,
    appearance           VARCHAR(16)  NOT NULL,
    icon                 VARCHAR(16)  NOT NULL,
    dismissible          BOOLEAN      NOT NULL,
    audience             VARCHAR(16)  NOT NULL,
    placement            VARCHAR(32)  NOT NULL,
    page_targets         JSON         NOT NULL,
    start_at             DATETIME(6)  DEFAULT NULL,
    end_at               DATETIME(6)  DEFAULT NULL,
    presentation_hash    CHAR(64)     NOT NULL,
    effective_at         DATETIME(6)  NOT NULL,
    actor                VARCHAR(255) NOT NULL,
    PRIMARY KEY (uuid),
    CONSTRAINT fk_banner_version_occurrence
        FOREIGN KEY (banner_uuid) REFERENCES banner_occurrence (uuid),
    CONSTRAINT uq_banner_version_number UNIQUE (banner_uuid, version_number)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_bin;

INSERT INTO banner_version (
    uuid, banner_uuid, version_number, html_content, title, appearance, icon, dismissible, audience, placement,
    page_targets, start_at, end_at, presentation_hash, effective_at, actor
)
SELECT UUID_TO_BIN(UUID()), uuid, 1, html_content, title, appearance, icon, dismissible, audience, placement,
       page_targets, start_at, end_at, presentation_hash, published_at,
       COALESCE(NULLIF(published_by, ''), 'SYSTEM_MIGRATION')
FROM banner_occurrence
WHERE status = 'PUBLISHED';

DELIMITER //
CREATE TRIGGER banner_occurrence_version_after_insert
    AFTER INSERT ON banner_occurrence
    FOR EACH ROW
BEGIN
    IF NEW.status = 'PUBLISHED' THEN
        INSERT INTO banner_version (
            uuid, banner_uuid, version_number, html_content, title, appearance, icon, dismissible, audience, placement,
            page_targets, start_at, end_at, presentation_hash, effective_at, actor
        ) VALUES (
            UUID_TO_BIN(UUID()), NEW.uuid, 1, NEW.html_content, NEW.title, NEW.appearance, NEW.icon, NEW.dismissible,
            NEW.audience, NEW.placement, NEW.page_targets, NEW.start_at, NEW.end_at, NEW.presentation_hash,
            NEW.published_at, COALESCE(NULLIF(NEW.published_by, ''), 'SYSTEM_MIGRATION')
        );
    END IF;
END//

CREATE TRIGGER banner_occurrence_version_after_first_publish
    AFTER UPDATE ON banner_occurrence
    FOR EACH ROW
BEGIN
    IF OLD.status <> 'PUBLISHED' AND NEW.status = 'PUBLISHED' THEN
        INSERT INTO banner_version (
            uuid, banner_uuid, version_number, html_content, title, appearance, icon, dismissible, audience, placement,
            page_targets, start_at, end_at, presentation_hash, effective_at, actor
        ) VALUES (
            UUID_TO_BIN(UUID()), NEW.uuid, 1, NEW.html_content, NEW.title, NEW.appearance, NEW.icon, NEW.dismissible,
            NEW.audience, NEW.placement, NEW.page_targets, NEW.start_at, NEW.end_at, NEW.presentation_hash,
            NEW.published_at, COALESCE(NULLIF(NEW.published_by, ''), 'SYSTEM_MIGRATION')
        );
    END IF;
END//
DELIMITER ;
