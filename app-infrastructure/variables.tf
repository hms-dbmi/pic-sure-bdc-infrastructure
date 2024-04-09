variable "stack_githash" {
  type = string
}

variable "stack_githash_long" {
  type = string
}

variable "picsure_rds_snapshot_id" {
  description = "Snapshot id to use for picsure rds instance.  leave blank to create rds without a snapshot"
  type        = string
}

variable "target_stack" {
  description = "Green stack to target for deployment"
  type        = string
}

variable "stack_s3_bucket" {
  description = "S3 bucket for deployments"
  type        = string
}

variable "dataset_s3_object_key" {
  description = "The s3 object key within the environment s3 bucket"
  type        = string
}

variable "destigmatized_dataset_s3_object_key" {
  description = "The s3 object key within the environment s3 bucket"
  type        = string
}

variable "genomic_dataset_s3_object_key" {
  description = "The s3 object key within the environment s3 bucket"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment"
  type        = string
}

variable "env_staging_subdomain" {
  description = "Add Stack Tag"
  type        = string
}

variable "rds_master_username" {
  description = "Master Username"
  type        = string
  default     = "root"
}

variable "rds_master_password" {
  description = "Master Password"
  type        = string
  default     = "picsure!98765"
}

variable "env_public_dns_name" {
  type = string
}

variable "env_public_dns_name_staging" {
  type = string
}

variable "env_private_dns_name" {
  type = string
}

variable "env_hosted_zone_id" {
  type = string
}

variable "env_is_open_access" {
  type = bool
}

variable "include_auth_hpds" {
  type    = bool
}

variable "include_open_hpds" {
  type    = bool
}

# removing for now as they are secrets handled by the stack_variables
variable "picsure_token_introspection_token" {
  type    = string
  default = ""
}

variable "picsure_client_secret" {
  type    = string
  default = ""
}

variable "fence_client_secret" {
  type    = string
  default = ""
}
variable "fence_client_id" {
  type    = string
  default = ""
}

variable "idp_provider_uri" {
  type    = string
  default = "https://gen3.biodatacatalyst.nhlbi.nih.gov"
}

variable "idp_provider" {
  type    = string
  default = "fence"
}

variable "application_id_for_base_query" {
  type = string
}

variable "analytics_id" {
  type = string
  default = "__ANALYTICS_ID__"
}

variable "tag_manager_id" {
  type = string
  default = "__TAG_MANAGER_ID__"
}

variable "env_project" {
  type = string
}

variable "environment_prefix" {
  type = string
  default = "bdc"
}

variable "help_link" {
  type = string
  default = "https://bdcatalyst.freshdesk.com/support/home"
}

variable "login_link" {
  type = string
  description = "Relative or absolute URL to redirect to upon login"
  default = "/psamaui/login/?redirection_url=/picsureui/"
}

variable "client_id" {
  default = "not_used_in_fence"
  type = string
  description = "Service Provider Client ID"
}

variable "sp_client_secret" {
  default = ""
  type = string
  description = "Service Provider Client Secret"
}
variable "connection_label" {
  default = "FENCE"
  type = string
}
variable "connection_sub_prefix" {
  default = "fence|"
  type = string
}

variable "connection_id" {
  default = "Fence"
  type = string
}

variable "pdf_link" {
  type = string
  default = "https://tinyurl.com/BDC-PIC-SURE-User-Guide"
}

variable "picsure_db_host" {
    type = string
    description = "The host for the picsure db"
}

variable "picsure_db_password" {
    type = string
    description = "The password for the picsure db"
}

variable "picsure_db_username" {
    type = string
    description = "The username for the picsure db"
}

variable "referer_allowed_domains" {
    type = string
    description = "The referer allowed domains. A regex string to match the referer domain"
}

variable "pic_sure_resource_id" {
    type = string
    description = "The resource id for the pic-sure. Used for auth or open HPDS generally"
}

variable "app_acct_id" {
    type = string
    description = "The account id for the application"
}

variable "app_user_secret_name" {
    type = string
    description = "The secret name for the application user"
}