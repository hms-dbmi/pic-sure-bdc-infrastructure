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
  default     = true
}

variable "render_open_hpds" {
  description = "Whether to render and upload the open HPDS env file"
  type        = bool
  default     = true
}
