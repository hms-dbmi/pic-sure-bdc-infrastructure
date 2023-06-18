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

variable "jenkins_provisioning_assume_role_name" {
  type = string
}

variable "jenkins_provisioning_assume_role_duration" {
  type = number
}