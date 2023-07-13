variable "stack_githash" {
  type = string
}
variable "stack_githash_long" {
  type = string
}

variable "target-stack" {
  description = "The stack identifier"
  type        = string
}

variable "dataset-s3-object-key" {
  description = "The s3 object key within the environment s3 bucket"
  type        = string
}

variable "destigmatized-dataset-s3-object-key" {
  description = "The s3 object key within the environment s3 bucket"
  type        = string
}

variable "genomic-dataset-s3-object-key" {
  description = "The s3 object key within the environment s3 bucket"
  type        = string
}

variable "source_dictionary_s3_object_key" {
  description = "The s3 object key for the data dictionary"
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

variable "allowed_hosts" {
  description = "List of allowed hosts for hosts header validation"
  type        = string
  default     = ""
}
