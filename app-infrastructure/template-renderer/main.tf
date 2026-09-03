resource "aws_s3_object" "hpds_auth_env" {
  count = var.render_auth_hpds ? 1 : 0

  bucket = var.stack_s3_bucket
  key    = "configs/hpds/${var.target_stack}/auth-hpds.env"
  content = templatefile("${path.module}/templates/hpds-auth.env.tftpl", {
    environment_name     = var.environment_name
    target_stack         = var.target_stack
    env_private_dns_name = var.env_private_dns_name
  })

  content_type           = "text/plain"
  server_side_encryption = "AES256"
}

resource "aws_s3_object" "hpds_open_env" {
  count = var.render_open_hpds ? 1 : 0

  bucket  = var.stack_s3_bucket
  key     = "configs/hpds/${var.target_stack}/open-hpds.env"
  content = templatefile("${path.module}/templates/hpds-open.env.tftpl", {})

  content_type           = "text/plain"
  server_side_encryption = "AES256"
}

resource "aws_s3_object" "visualization_env" {
  count = var.render_visualization ? 1 : 0

  bucket = var.stack_s3_bucket
  key    = "configs/pic-sure-visualization/${var.target_stack}/visualization.env"
  # No stack/DNS interpolation: visualization now reaches pic-sure-hpds-query-service by podman DNS on the
  # shared network, so the template carries no per-stack HPDS host.
  content = templatefile("${path.module}/templates/visualization.env.tftpl", {
    logging_api_key = var.logging_api_key
  })

  content_type           = "text/plain"
  server_side_encryption = "AES256"
}

# ---- Gateway-rewrite service env files -------------------------------------
# Each of the three renders behind its own flag now. query_service_internal_token,
# picsure_application_token, and (for query.env) aggregate_obfuscation_salt are
# supplied by the caller and must be byte-identical across gateway.env,
# operations.env, and query.env.

data "aws_secretsmanager_secret_version" "picsure_app_user" {
  count     = var.render_operations ? 1 : 0
  secret_id = var.app_user_secret_name
}

locals {
  picsure_app_user = var.render_operations ? jsondecode(data.aws_secretsmanager_secret_version.picsure_app_user[0].secret_string) : {}
}

resource "aws_s3_object" "gateway_env" {
  count  = var.render_gateway ? 1 : 0
  bucket = var.stack_s3_bucket
  key    = "configs/gateway/${var.target_stack}/gateway.env"
  content = templatefile("${path.module}/templates/gateway.env.tftpl", {
    target_stack                      = var.target_stack
    env_private_dns_name              = var.env_private_dns_name
    picsure_token_introspection_token = var.picsure_token_introspection_token
    logging_api_key                   = var.logging_api_key
    include_open_hpds                 = var.include_open_hpds
    picsure_application_token         = var.picsure_application_token
    query_service_internal_token      = var.query_service_internal_token
  })

  content_type           = "text/plain"
  server_side_encryption = "AES256"

  lifecycle {
    precondition {
      condition     = var.picsure_application_token != ""
      error_message = "picsure_application_token is empty; check the render job's TF_VAR_picsure_application_token export."
    }
    precondition {
      condition     = var.query_service_internal_token != ""
      error_message = "query_service_internal_token is empty; check the render job's TF_VAR_query_service_internal_token export."
    }
  }
}

resource "aws_s3_object" "operations_env" {
  count  = var.render_operations ? 1 : 0
  bucket = var.stack_s3_bucket
  key    = "configs/operations/${var.target_stack}/operations.env"
  content = templatefile("${path.module}/templates/operations.env.tftpl", {
    picsure_db_host              = local.picsure_app_user["host"]
    picsure_db_username          = local.picsure_app_user["username"]
    picsure_db_password          = local.picsure_app_user["password"]
    picsure_application_token    = var.picsure_application_token
    query_service_internal_token = var.query_service_internal_token
  })

  content_type           = "text/plain"
  server_side_encryption = "AES256"

  lifecycle {
    precondition {
      condition     = var.picsure_application_token != ""
      error_message = "picsure_application_token is empty; check the render job's TF_VAR_picsure_application_token export."
    }
    precondition {
      condition     = var.query_service_internal_token != ""
      error_message = "query_service_internal_token is empty; check the render job's TF_VAR_query_service_internal_token export."
    }
  }
}

resource "aws_s3_object" "query_env" {
  count  = var.render_query ? 1 : 0
  bucket = var.stack_s3_bucket
  key    = "configs/query/${var.target_stack}/query.env"
  content = templatefile("${path.module}/templates/query.env.tftpl", {
    target_stack                 = var.target_stack
    env_private_dns_name         = var.env_private_dns_name
    aggregate_obfuscation_salt   = var.aggregate_obfuscation_salt
    picsure_application_token    = var.picsure_application_token
    query_service_internal_token = var.query_service_internal_token
  })

  content_type           = "text/plain"
  server_side_encryption = "AES256"

  lifecycle {
    precondition {
      condition     = var.picsure_application_token != ""
      error_message = "picsure_application_token is empty; check the render job's TF_VAR_picsure_application_token export."
    }
    precondition {
      condition     = var.query_service_internal_token != ""
      error_message = "query_service_internal_token is empty; check the render job's TF_VAR_query_service_internal_token export."
    }
    precondition {
      condition     = var.aggregate_obfuscation_salt != ""
      error_message = "aggregate_obfuscation_salt is empty; check the render job's TF_VAR_aggregate_obfuscation_salt export."
    }
  }
}

# ---- Stack-independent shared service env files ------------------------------
# One logging, dictionary, and PSAMA instance serves every stack, so unlike the six
# resources above these three S3 keys carry no target_stack segment. The paths below
# are the ones deploy-logging.sh, deploy-dictionary.sh, and deploy-psama.sh already
# fetch; changing them breaks every deploy.

resource "aws_s3_object" "logging_env" {
  count  = var.render_logging ? 1 : 0
  bucket = var.stack_s3_bucket
  key    = "configs/pic-sure-logging/logging.env"
  content = templatefile("${path.module}/templates/logging.env.tftpl", {
    logging_api_key  = var.logging_api_key
    environment_name = var.environment_name
  })

  content_type           = "text/plain"
  server_side_encryption = "AES256"

  lifecycle {
    precondition {
      condition     = var.logging_api_key != ""
      error_message = "logging_api_key is empty; check the render job's TF_VAR_logging_api_key export."
    }
  }
}

resource "aws_s3_object" "dictionary_env" {
  count  = var.render_dictionary ? 1 : 0
  bucket = var.stack_s3_bucket
  key    = "configs/picsure-dictionary/picsure-dictionary.env"
  content = templatefile("${path.module}/templates/picsure-dictionary.env.tftpl", {
    dictionary_datasource_url      = var.dictionary_datasource_url
    dictionary_datasource_username = var.dictionary_datasource_username
  })

  content_type           = "text/plain"
  server_side_encryption = "AES256"

  lifecycle {
    precondition {
      condition     = var.dictionary_datasource_url != ""
      error_message = "dictionary_datasource_url is empty; check the render job's TF_VAR_dictionary_datasource_url export."
    }
    precondition {
      condition     = var.dictionary_datasource_username != ""
      error_message = "dictionary_datasource_username is empty; check the render job's TF_VAR_dictionary_datasource_username export."
    }
  }
}

# PSAMA is a different risk class from every other service in this module. Its IdP and
# application secrets are issued by Okta, Gen3 Fence, NIH RAS, and the mail provider,
# so nothing here can mint a replacement and each one is abort-only: blank fails the
# render rather than falling back to a generated or defaulted value. The three IdP
# client secrets are gated on their own provider flag, because demanding a secret for
# a provider that is switched off would only teach operators to invent placeholders.
# application_client_secret and email_password have no provider flag, so they gate
# unconditionally.
#
# Seven of its values are read off the live psama.env rather than guessed here, because
# each shapes authentication or authorization and a key-set comparison cannot see a
# wrong value. Four are booleans -- enable_public_access,
# consent_based_authorization_enabled, tos_enabled, and
# application_client_secret_is_base_64 -- and carry variable validation pinning them to
# exactly true or false, which unlike a precondition applies on every render regardless
# of count. Three are lists or claim names -- strict_authorization_applications,
# token_inclusion_roles, and user_id_claim -- and carry a precondition only, because any
# allowlist for them would reject a valid configuration.
#
# All seven default to the empty string and are asserted non-empty below. The empty
# default is deliberate: a variable with no default at all is required on every
# invocation of this module, which would break the six renders that never touch PSAMA.
# See the comment blocks in variables.tf and templates/psama.env.tftpl for the
# individual failure modes.

resource "aws_s3_object" "psama_env" {
  count  = var.render_psama ? 1 : 0
  bucket = var.stack_s3_bucket
  key    = "configs/psama/psama.env"
  content = templatefile("${path.module}/templates/psama.env.tftpl", {
    psama_datasource_url                 = var.psama_datasource_url
    psama_datasource_username            = var.psama_datasource_username
    enable_public_access                 = var.enable_public_access
    strict_authorization_applications    = var.strict_authorization_applications
    consent_based_authorization_enabled  = var.consent_based_authorization_enabled
    tos_enabled                          = var.tos_enabled
    application_client_secret            = var.application_client_secret
    application_client_secret_is_base_64 = var.application_client_secret_is_base_64
    user_id_claim                        = var.user_id_claim
    token_inclusion_roles                = var.token_inclusion_roles
    stack_specific_application_id        = var.stack_specific_application_id
    admin_users                          = var.admin_users
    email_address                        = var.email_address
    email_password                       = var.email_password
    grant_email_subject                  = var.grant_email_subject
    user_activation_reply_to             = var.user_activation_reply_to
    include_open_hpds                    = var.include_open_hpds
    a4_okta_idp_provider_is_enabled      = var.a4_okta_idp_provider_is_enabled
    a4_okta_client_id                    = var.a4_okta_client_id
    a4_okta_client_secret                = var.a4_okta_client_secret
    a4_okta_connection_id                = var.a4_okta_connection_id
    a4_okta_idp_provider_uri             = var.a4_okta_idp_provider_uri
    fence_idp_provider_is_enabled        = var.fence_idp_provider_is_enabled
    fence_idp_provider_uri               = var.fence_idp_provider_uri
    fence_client_id                      = var.fence_client_id
    fence_client_secret                  = var.fence_client_secret
    auth0_idp_provider_is_enabled        = var.auth0_idp_provider_is_enabled
    auth0_host                           = var.auth0_host
    auth0_denied_email_enabled           = var.auth0_denied_email_enabled
    ras_okta_idp_provider_is_enabled     = var.ras_okta_idp_provider_is_enabled
    ras_okta_idp_provider_uri            = var.ras_okta_idp_provider_uri
    ras_okta_connection_id               = var.ras_okta_connection_id
    ras_okta_client_id                   = var.ras_okta_client_id
    ras_okta_client_secret               = var.ras_okta_client_secret
    ras_idp_uri                          = var.ras_idp_uri
    ras_passport_issuer                  = var.ras_passport_issuer
    devtools_secret                      = var.devtools_secret
  })

  content_type           = "text/plain"
  server_side_encryption = "AES256"

  lifecycle {
    precondition {
      condition     = var.enable_public_access != ""
      error_message = "enable_public_access is empty; check the render job's TF_VAR_enable_public_access export. This flag fails open and must never be rendered from a fallback."
    }
    precondition {
      condition     = var.strict_authorization_applications != ""
      error_message = "strict_authorization_applications is empty; check the render job's TF_VAR_strict_authorization_applications export. This flag fails open and must never be rendered from a fallback."
    }
    precondition {
      condition     = var.consent_based_authorization_enabled != ""
      error_message = "consent_based_authorization_enabled is empty; check the render job's TF_VAR_consent_based_authorization_enabled export. Read it off the live psama.env rather than guessing: it decides whether consent is evaluated for authorization at all."
    }
    precondition {
      condition     = var.tos_enabled != ""
      error_message = "tos_enabled is empty; check the render job's TF_VAR_tos_enabled export. Read it off the live psama.env rather than guessing: turning terms-of-service acceptance on blocks every login until each user accepts."
    }
    precondition {
      condition     = var.application_client_secret != ""
      error_message = "application_client_secret is empty; check the render job's TF_VAR_application_client_secret export. It cannot be regenerated."
    }
    precondition {
      condition     = var.application_client_secret_is_base_64 != ""
      error_message = "application_client_secret_is_base_64 is empty; check the render job's TF_VAR_application_client_secret_is_base_64 export. Read it off the live psama.env rather than guessing: a wrong value changes the JWT signing key bytes and silently invalidates every issued token."
    }
    precondition {
      condition     = var.user_id_claim != ""
      error_message = "user_id_claim is empty; check the render job's TF_VAR_user_id_claim export. Read it off the live psama.env rather than guessing: it names the JWT claim that identifies the caller on every request."
    }
    precondition {
      condition     = var.token_inclusion_roles != ""
      error_message = "token_inclusion_roles is empty; check the render job's TF_VAR_token_inclusion_roles export. Read it off the live psama.env rather than guessing: it is the allowlist of roles embedded in issued JWTs and read downstream for authorization."
    }
    precondition {
      condition     = !var.a4_okta_idp_provider_is_enabled || var.a4_okta_client_secret != ""
      error_message = "a4_okta_idp_provider_is_enabled is true but a4_okta_client_secret is empty; check the render job's TF_VAR_a4_okta_client_secret export. Okta issues it and it cannot be regenerated."
    }
    precondition {
      condition     = !var.ras_okta_idp_provider_is_enabled || var.ras_okta_client_secret != ""
      error_message = "ras_okta_idp_provider_is_enabled is true but ras_okta_client_secret is empty; check the render job's TF_VAR_ras_okta_client_secret export. Okta issues it and it cannot be regenerated."
    }
    precondition {
      condition     = !var.fence_idp_provider_is_enabled || var.fence_client_secret != ""
      error_message = "fence_idp_provider_is_enabled is true but fence_client_secret is empty; check the render job's TF_VAR_fence_client_secret export. Gen3 Fence issues it and it cannot be regenerated."
    }
    precondition {
      condition     = var.email_password != ""
      error_message = "email_password is empty; check the render job's TF_VAR_email_password export. The mail provider issues it and it cannot be regenerated."
    }
    precondition {
      condition     = var.psama_datasource_url != ""
      error_message = "psama_datasource_url is empty; check the render job's TF_VAR_psama_datasource_url export."
    }
    precondition {
      condition     = var.psama_datasource_username != ""
      error_message = "psama_datasource_username is empty; check the render job's TF_VAR_psama_datasource_username export."
    }
  }
}
