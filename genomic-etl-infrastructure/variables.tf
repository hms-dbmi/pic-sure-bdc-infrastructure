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


variable "output_s3_bucket"{
  type = string
}
    
variable "input_s3_bucket"{
  type = string
}

    
variable "study_id"{
  type = string
}
    
    
variable "chrom_number"{
  type = string
}
    
    
variable "study_consent_group"{
  type = string
}
    
    
variable "consent_group_tag"{
  type = string
}


