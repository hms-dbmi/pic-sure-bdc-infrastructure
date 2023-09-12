variable "stack_githash" {
  type = string
}

variable "stack_githash_long" {
  type = string
}


variable "target_stack" {
  description = "The stack identifier"
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
variable "env_private_dns_name" {
  type = string
}

variable "env_hosted_zone_id" {
  type = string
}

variable "env_is_open_access" {
  type    = bool
}

variable "include_auth_hpds" {
    type    = bool
}

variable "include_open_hpds" {
    type    = bool
}

# removing for now as they are secrets handled by the stack_variables
#variable "picsure_token_introspection_token" {
#  type    = string
#}
#
#variable "picsure_client_secret" {
#  type    = string
#}
#
#variable "fence_client_secret" {
#  type    = string
#  default = ""
#}
#variable "fence_client_id" {
#  type    = string
#  default = ""
#}

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
}