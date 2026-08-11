## Service Configuration

WildFly and its `standalone.xml`/`module.xml` configuration are gone — the PIC-SURE API is served
by the `gateway`, `pic-sure-operations-service`, and `pic-sure-hpds-query-service` containers.
Their env files are rendered by `../template-renderer` (see `templates/{gateway,operations,query}.env.tftpl`)
and uploaded to S3 at `configs/{gateway,operations,query}/<target_stack>/`.

This directory holds the remaining Terraform-rendered config templates: the httpd vhosts
(`httpd-vhosts-{bdc,aim-ahead}.conf`), frontend settings (`picsureui_settings.json`,
`banner_config.json`), and HPDS logging/env examples.
