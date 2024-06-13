variable "app_user_secret_name" {
    description = "The name of the secret in Secrets Manager that contains the username for the application to connect to the database"
    type        = string
}

variable "picsure_db_host" {
    description = "The hostname of the database server"
    type        = string
}

variable "application_id_for_base_query" {
    description = "The application ID to use for the base query"
    type        = string
}

variable "idp_provider" {
    description = "The IDP provider to use"
    type        = string
}

variable "idp_provider_uri" {
    description = "The URI of the IDP provider"
    type        = string
}

variable "picsure_client_secret" {
    description = "The client secret for the application"
    type        = string
}

variable "fence_client_id" {
    description = "The client ID for the application to connect to Fence"
    type        = string
}

variable "fence_client_secret" {
    description = "The client secret for the application to connect to Fence"
    type        = string
}

variable "fence_idp_provider_uri" {
    description = "The URI of the IDP provider for Fence"
    type        = string
}

variable "fence_idp_provider_is_enabled" {
    description = "Whether the Fence IDP provider is enabled"
    type        = bool
}

variable "a4_okta_client_id" {
    description = "The client ID for the application to connect to AIM-AHEAD"
    type        = string
}

variable "a4_okta_client_secret" {
    description = "The client secret for the application to connect to AIM-AHEAD"
    type        = string
}

variable "a4_okta_idp_provider_uri" {
    description = "The URI of the IDP provider for AIM-AHEAD"
    type        = string
}

variable "a4_okta_idp_provider_is_enabled" {
    description = "Whether the AIM-AHEAD IDP provider is enabled"
    type        = bool
}

variable "auth0_idp_provider_uri" {
    description = "The URI of the IDP provider for Auth0"
    type        = string
}

variable "auth0_host" {
    description = "The hostname of the Auth0 server"
    type        = string
}

variable "auth0_denied_email_enabled" {
    description = "Whether to send an email when a user is denied access"
    type        = bool
}

variable "auth0_idp_provider_is_enabled" {
    description = "Whether the Auth0 IDP provider is enabled"
    type        = bool
}

variable "open_idp_provider_is_enabled" {
    description = "Whether the Open IDP provider is enabled"
    type        = bool
}