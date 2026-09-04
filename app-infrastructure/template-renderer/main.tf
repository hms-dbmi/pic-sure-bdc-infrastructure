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

  lifecycle {
    precondition {
      condition     = var.logging_api_key != ""
      error_message = "logging_api_key is empty; check the render job's TF_VAR_logging_api_key export."
    }
  }
}

# picsure_application_token and query_service_internal_token must be byte-identical
# across gateway.env, operations.env, and query.env.

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
    precondition {
      condition     = var.logging_api_key != ""
      error_message = "logging_api_key is empty; check the render job's TF_VAR_logging_api_key export."
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

# Shared-object service env files
# These two keys carry no target_stack segment, so one object serves every stack. Each
# stack still runs its own pic-sure-logging and picsure-dictionary container. A change to
# either object therefore reaches every stack at once, and LOGGING_API_KEY cannot be
# re-minted for one stack alone. deploy-logging.sh and deploy-dictionary.sh already fetch
# these paths; changing them breaks every deploy.

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
