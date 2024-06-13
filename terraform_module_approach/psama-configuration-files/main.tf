provider "aws" {
  region  = "us-east-1"
  profile = "avillachlab-secure-infrastructure"
  version = "3.74"
}

data "template_file" "psama-env" {
  template = file("${path.module}/configs/psama.env")
  vars = {
    datasource_username             = var.app_user_secret_name,
    picsure_db_host                 = var.picsure_db_host,
    stack_specific_application_id   = var.application_id_for_base_query,
    client_secret                   = var.picsure_client_secret,
    system_name                     = "PIC-SURE BioDataCatalyst",
    fence_client_id                 = var.fence_client_id,
    fence_client_secret             = var.fence_client_secret,
    fence_idp_provider_uri          = var.fence_idp_provider_uri,
    fence_idp_provider_is_enabled   = var.fence_idp_provider_is_enabled,
    a4_okta_client_id               = var.a4_okta_client_id,
    a4_okta_client_secret           = var.a4_okta_client_secret,
    a4_okta_idp_provider_uri        = var.a4_okta_idp_provider_uri
    a4_okta_idp_provider_is_enabled = var.a4_okta_idp_provider_is_enabled,
    open_idp_provider_is_enabled    = var.open_idp_provider_is_enabled,
    auth0_idp_provider_uri          = var.auth0_idp_provider_uri,
    auth0_host                      = var.auth0_host,
    auth0_denied_email_enabled      = var.auth0_denied_email_enabled,
    auth0_idp_provider_is_enabled   = var.auth0_idp_provider_is_enabled,
  }

  filename = "${path.module}/output/psama.env"
}

resource "local_file" "psama-env-file" {
  filename = "psama.env"
  content  = data.template_file.psama-env.rendered
}