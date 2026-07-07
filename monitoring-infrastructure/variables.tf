variable "environment_name" {
  description = "The name of the environment"
  type        = string
}

variable "stack_s3_bucket" {
  description = "S3 bucket for deployments"
  type        = string
}

variable "env_private_dns_name" {
  # kept for shared-tfvars compatibility; unused in this module
  type = string
}

variable "environment_prefix" {
  type    = string
  default = "bdc"
}

variable "env_is_open_access" {
  type = bool
}

variable "env_project" {
  type = string
}

variable "monitoring_instance_type" {
  description = "EC2 instance type for the monitoring host"
  type        = string
  default     = "m7a.large"
}

variable "monitoring_volume_size_gb" {
  description = "Root volume size (GB) for the monitoring host"
  type        = number
  default     = 100
}
