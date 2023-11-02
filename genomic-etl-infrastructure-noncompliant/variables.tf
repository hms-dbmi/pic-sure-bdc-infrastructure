variable "deployment_githash" {
  type = string
}
variable "deployment_githash_long" {
  type = string
}

variable "ami-id" {
  description = "AMI to use for all ec2s"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment"
  type        = string
  default     = "genomic etl"
}
    
variable "study_consent_group"{
  type = string
}
    
    
variable "consent_group_tag"{
  type = string
}