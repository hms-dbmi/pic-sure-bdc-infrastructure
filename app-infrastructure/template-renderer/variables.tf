variable "stack_s3_bucket" {
  description = "S3 bucket for deployment artifacts and configuration"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment (e.g., dev, staging, prod)"
  type        = string
}

variable "target_stack" {
  description = "The target stack identifier (e.g., a, b)"
  type        = string
}

variable "env_private_dns_name" {
  description = "The private DNS name for the environment"
  type        = string
}

variable "render_auth_hpds" {
  description = "Whether to render and upload the auth HPDS env file"
  type        = bool
  default     = false
}

variable "render_open_hpds" {
  description = "Whether to render and upload the open HPDS env file"
  type        = bool
  default     = false
}

variable "render_visualization" {
  description = "Whether to render and upload the visualization env file"
  type        = bool
  default     = false
}

variable "render_gateway" {
  description = "Whether to render and upload the gateway env file"
  type        = bool
  default     = false
}

variable "render_operations" {
  description = "Whether to render and upload the operations env file"
  type        = bool
  default     = false
}

variable "render_query" {
  description = "Whether to render and upload the query env file"
  type        = bool
  default     = false
}

variable "picsure_token_introspection_token" {
  description = "PSAMA_APPLICATION service JWT for gateway token introspection"
  type        = string
  default     = ""
  sensitive   = true
}

variable "picsure_application_token" {
  description = "Shared application token consumed by gateway.env, operations.env, and query.env"
  type        = string
  default     = ""
  sensitive   = true
}

variable "query_service_internal_token" {
  description = "Internal query-service token consumed by gateway.env, operations.env, and query.env"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aggregate_obfuscation_salt" {
  description = "Aggregate obfuscation salt consumed by query.env"
  type        = string
  default     = ""
  sensitive   = true
}

variable "logging_api_key" {
  description = "API key for the pic-sure-logging service"
  type        = string
  default     = ""
  sensitive   = true
}

variable "app_user_secret_name" {
  description = "Secrets Manager secret holding the picsure app DB user (username/password/host)"
  type        = string
  default     = ""
}

variable "include_open_hpds" {
  description = "Whether open access is enabled (drives GATEWAY_OPEN_ACCESS_ENABLED)"
  type        = bool
  # Fail closed: open (unauthenticated) access must be opted into explicitly. A
  # missing -var must never silently enable GATEWAY_OPEN_ACCESS_ENABLED.
  default = false
}

variable "render_logging" {
  description = "Whether to render and upload the pic-sure-logging env file"
  type        = bool
  default     = false
}

variable "render_dictionary" {
  description = "Whether to render and upload the picsure-dictionary env file"
  type        = bool
  default     = false
}

# ---- Dictionary datasource ---------------------------------------------------
# The bdc profile drives the AWS Secrets Manager PostgreSQL JDBC driver, so the
# username is a Secrets Manager secret id and the driver reads the real username and
# password out of that secret. No database password is a variable here, by design.
# Neither value is marked sensitive, matching app_user_secret_name; the render job
# should still pass both as TF_VAR_* rather than -var so they stay off the command line.

variable "dictionary_datasource_url" {
  description = "Bare database host for picsure-dictionary; application-bdc.properties wraps it into the jdbc-secretsmanager URL"
  type        = string
  default     = ""
}

variable "dictionary_datasource_username" {
  description = "Secrets Manager secret id holding the picsure-dictionary database credentials"
  type        = string
  default     = ""
}

