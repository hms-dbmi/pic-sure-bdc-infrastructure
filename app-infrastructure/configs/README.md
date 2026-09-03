## Service Configuration

WildFly and its `standalone.xml`/`module.xml` configuration are gone — the PIC-SURE API is served
by the `gateway`, `pic-sure-operations-service`, and `pic-sure-hpds-query-service` containers.
Eight service env files are rendered by `../template-renderer`. Six carry a stack segment:
`templates/{gateway,operations,query}.env.tftpl` upload to `configs/{gateway,operations,query}/<target_stack>/`,
`templates/{hpds-auth,hpds-open}.env.tftpl` to `configs/hpds/<target_stack>/`, and
`templates/visualization.env.tftpl` to `configs/pic-sure-visualization/<target_stack>/`. Two do not:
`templates/logging.env.tftpl` uploads to `configs/pic-sure-logging/logging.env` and
`templates/picsure-dictionary.env.tftpl` to `configs/picsure-dictionary/picsure-dictionary.env`.
Those two keys have no stack segment, so every stack's deploy pulls the same file. The `.tftpl` under
`templates/` is the file to edit; the rendered `.env` in S3 is a build artifact, not a source file.

This directory holds the remaining Terraform-rendered config templates: the httpd vhosts
(`httpd-vhosts-{bdc,aim-ahead}.conf`), frontend settings (`picsureui_settings.json`,
`banner_config.json`), and HPDS logging/env examples.
