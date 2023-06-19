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


variable "ami-id" {
  description = "AMI to use for all ec2s"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment"
  type        = string
  default     = "picsure"
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
  type        = string
}
variable "env_private_dns_name" {
  type        = string
}

variable "dsm_url" {
  type = string
}
