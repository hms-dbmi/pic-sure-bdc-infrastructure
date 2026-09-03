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

variable "render_psama" {
  description = "Whether to render and upload the PSAMA env file"
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

# ---- PSAMA datasource --------------------------------------------------------
# Same Secrets Manager driver arrangement as the dictionary, via the MySQL driver
# configured in config/psama/bdc/psama-db-config.properties.

variable "psama_datasource_url" {
  description = "Bare database host for PSAMA; psama-db-config.properties wraps it into the jdbc-secretsmanager URL"
  type        = string
  default     = ""
}

variable "psama_datasource_username" {
  description = "Secrets Manager secret id holding the PSAMA database credentials"
  type        = string
  default     = ""
}

# ---- PSAMA behaviour flags: supply these, never guess them -------------------
# Four flags whose value has to come off the live psama.env rather than out of a
# source default, because getting one wrong is either an authorization hole or an
# outage.
#
# ENABLE_PUBLIC_ACCESS=true drops PSAMA's auth-path guard; with consent-based
# authorization also off, a tokenless caller read every synthetic patient in the
# database unscoped (verified 2026-09-02; memory/public-access-flag-opens-auth-backend.md).
#
# STRICT_AUTHORIZATION_APPLICATIONS lists the connections that require BOTH access
# rules and privilege rules. An empty merged rule set GRANTS on a connection absent
# from this list and DENIES on one present in it, so a short list silently converts
# denies into grants (memory/empty-access-rules-fail-open-or-closed.md).
#
# CONSENT_BASED_AUTHORIZATION_ENABLED decides whether consent is evaluated for
# authorization at all. user_consents is the sole consent source for v3 queries, so
# turning it off stops per-consent scoping and changes who can see which studies. It is
# also the other half of the ENABLE_PUBLIC_ACCESS finding: that unscoped read needed
# both flags.
#
# TOS_ENABLED does not fail open, but it cannot be guessed either. Pinning it to the
# source default of true would turn terms-of-service acceptance on and block every
# login on first render if the live file says false, and the compare job that guards
# this migration diffs key sets only, so it cannot catch a wrong value.
#
# All four default to the empty string and are asserted non-empty by preconditions on
# aws_s3_object.psama_env, which is what makes a forgotten value fail the render
# instead of rendering a guess. The empty default rather than no default at all is
# deliberate: Terraform requires a value for a no-default variable on every invocation
# of the module regardless of which resources count in, which would break the six
# renders that never touch PSAMA.
#
# The three boolean flags additionally restrict their value to exactly "true" or
# "false" through a validation block. A non-empty check alone is not enough: Spring's
# string-to-boolean conversion also accepts "yes", "on", and "1" as true, so a
# read-back that returned "yes" would satisfy every precondition here and still flip
# the flag on. Validation is the right mechanism rather than another precondition
# because it runs against the variable itself no matter what any resource's count is,
# so a bad value is rejected on every render and not only on PSAMA ones.
# strict_authorization_applications deliberately has no validation: it is a
# comma-separated application list, and any allowlist for it would be guesswork.

variable "enable_public_access" {
  description = "PSAMA ENABLE_PUBLIC_ACCESS, as the literal string \"true\" or \"false\". Fails open; read it off the live psama.env"
  type        = string
  default     = ""

  validation {
    condition     = contains(["", "true", "false"], var.enable_public_access)
    error_message = "enable_public_access must be exactly \"true\" or \"false\", or empty (which the render_psama precondition then rejects). Spring also reads \"yes\", \"on\", and \"1\" as true, so anything looser here could open the auth backend."
  }
}

variable "strict_authorization_applications" {
  description = "Comma-separated PSAMA connections that require both access rules and privilege rules (application.properties fallback: OKTA,FENCE,OPEN,RAS). Fails open; read it off the live psama.env"
  type        = string
  default     = ""
}

variable "consent_based_authorization_enabled" {
  description = "PSAMA CONSENT_BASED_AUTHORIZATION_ENABLED, as the literal string \"true\" or \"false\". Read it off the live psama.env; it decides whether consent is evaluated for authorization at all"
  type        = string
  default     = ""

  validation {
    condition     = contains(["", "true", "false"], var.consent_based_authorization_enabled)
    error_message = "consent_based_authorization_enabled must be exactly \"true\" or \"false\", or empty (which the render_psama precondition then rejects). Spring also reads \"yes\", \"on\", and \"1\" as true, so anything looser here could change how consent is evaluated."
  }
}

variable "tos_enabled" {
  description = "PSAMA TOS_ENABLED, as the literal string \"true\" or \"false\". Read it off the live psama.env; a wrong value blocks every login until each user accepts"
  type        = string
  default     = ""

  validation {
    condition     = contains(["", "true", "false"], var.tos_enabled)
    error_message = "tos_enabled must be exactly \"true\" or \"false\", or empty (which the render_psama precondition then rejects). Spring also reads \"yes\", \"on\", and \"1\" as true."
  }
}

# ---- PSAMA secrets that cannot be minted ------------------------------------
# Okta, Gen3 Fence, NIH RAS, and the mail provider issue these. Nothing in this module
# can regenerate one, so read-back is abort-only: each defaults to the empty string and
# a precondition on aws_s3_object.psama_env fails the render when it stays empty. Never
# give one of these a generated fallback or a non-empty default.
#
# The three IdP client secrets gate conditionally, each on its own provider flag: a
# provider that is switched off needs no secret, and demanding one anyway would only
# teach operators to invent a placeholder. application_client_secret and email_password
# have no provider flag and gate unconditionally.

variable "application_client_secret" {
  description = "PSAMA APPLICATION_CLIENT_SECRET; signs the PIC-SURE JWTs and has no fallback in application.properties"
  type        = string
  default     = ""
  sensitive   = true
}

variable "a4_okta_client_secret" {
  description = "Okta-issued client secret for the AIM AHEAD Authorized Access IdP"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ras_okta_client_secret" {
  description = "Okta-issued client secret for the NIH RAS IdP"
  type        = string
  default     = ""
  sensitive   = true
}

variable "fence_client_secret" {
  description = "Gen3 Fence-issued client secret for the Fence IdP"
  type        = string
  default     = ""
  sensitive   = true
}

variable "email_password" {
  description = "Mail provider password for PSAMA notification mail"
  type        = string
  default     = ""
  sensitive   = true
}

# ---- PSAMA devtools secret: carried but not gated ---------------------------
# spring-boot-devtools is an optional dependency and the Boot repackage goal drops it
# from the deployed jar, so spring.devtools.remote.secret is inert in the artifact BDC
# runs. The key stays in the template so the compare job does not report it as a key
# the template lacks, but there is no precondition: nobody should have to supply a
# value for something nothing reads.

variable "devtools_secret" {
  description = "PSAMA spring.devtools.remote.secret; inert because the Boot repackage goal excludes devtools from the deployed jar, so this is carried unenforced"
  type        = string
  default     = ""
  sensitive   = true
}

# ---- PSAMA application identity and notification mail -----------------------
# stack_specific_application_id feeds application.default.uuid and, despite the name,
# is one UUID shared by every stack. The mail values are cosmetic: a blank renders an
# empty setting, which beats the placeholder strings application.properties falls back
# to. admin_users is the denied-access notification recipient list and grants nothing.

variable "stack_specific_application_id" {
  description = "UUID for PSAMA application.default.uuid; one value for all stacks despite the name"
  type        = string
  default     = ""
}

variable "admin_users" {
  description = "Comma-separated recipient list for PSAMA denied-access notification mail"
  type        = string
  default     = ""
}

variable "email_address" {
  description = "From address for PSAMA notification mail"
  type        = string
  default     = ""
}

variable "grant_email_subject" {
  description = "Subject line for the PSAMA access-granted notification mail"
  type        = string
  default     = ""
}

variable "user_activation_reply_to" {
  description = "Reply-to address for the PSAMA user-activation notification mail"
  type        = string
  default     = ""
}

# ---- PSAMA identity providers ------------------------------------------------
# Each enablement flag is a bool defaulting to false, which is both the fail-closed
# direction -- a missing flag removes a login route rather than opening one -- and a
# real default, so none of these is required on a render that does not touch PSAMA.
#
# Each flag also gates its provider's client-secret precondition, so switching a
# provider off drops the demand for a secret nothing will use. BDC is not expected to
# run the AIM AHEAD Authorized Access or Auth0 providers at all.
#
# The ids, connection ids, and provider URIs are inert while their provider is
# disabled, which is why they default to the empty string and carry no precondition.
# PSAMA's open IdP is not listed here: the template reuses include_open_hpds so the
# open-access decision is stated once.

variable "a4_okta_idp_provider_is_enabled" {
  description = "Whether the AIM AHEAD Authorized Access Okta IdP is enabled in PSAMA"
  type        = bool
  default     = false
}

variable "a4_okta_client_id" {
  description = "Okta client id for the AIM AHEAD Authorized Access IdP"
  type        = string
  default     = ""
}

variable "a4_okta_connection_id" {
  description = "Okta connection id for the AIM AHEAD Authorized Access IdP"
  type        = string
  default     = ""
}

variable "a4_okta_idp_provider_uri" {
  description = "Okta provider URI for the AIM AHEAD Authorized Access IdP"
  type        = string
  default     = ""
}

variable "fence_idp_provider_is_enabled" {
  description = "Whether the Gen3 Fence IdP is enabled in PSAMA"
  type        = bool
  default     = false
}

variable "fence_idp_provider_uri" {
  description = "Gen3 Fence provider URI"
  type        = string
  default     = ""
}

variable "fence_client_id" {
  description = "Gen3 Fence client id"
  type        = string
  default     = ""
}

variable "auth0_idp_provider_is_enabled" {
  description = "Whether the Auth0 IdP is enabled in PSAMA"
  type        = bool
  default     = false
}

variable "auth0_host" {
  description = "Auth0 tenant host"
  type        = string
  default     = ""
}

variable "auth0_denied_email_enabled" {
  description = "Whether PSAMA sends the Auth0 denied-access notification mail"
  type        = bool
  default     = false
}

variable "ras_okta_idp_provider_is_enabled" {
  description = "Whether the NIH RAS Okta IdP is enabled in PSAMA"
  type        = bool
  default     = false
}

variable "ras_okta_idp_provider_uri" {
  description = "Okta provider URI brokering NIH RAS"
  type        = string
  default     = ""
}

variable "ras_okta_connection_id" {
  description = "Okta connection id for the NIH RAS IdP"
  type        = string
  default     = ""
}

variable "ras_okta_client_id" {
  description = "Okta client id for the NIH RAS IdP"
  type        = string
  default     = ""
}

variable "ras_idp_uri" {
  description = "NIH RAS issuer URI"
  type        = string
  default     = ""
}

variable "ras_passport_issuer" {
  description = "Expected issuer of NIH RAS GA4GH passports"
  type        = string
  default     = ""
}
