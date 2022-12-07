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
    
variable "input_s3_bucket"{
  type = string
}  
    
variable "study_consent_group"{
  type = string
}
    
    
variable "consent_group_tag"{
  type = string
}

variable "subnet_list"{
  type = list
}

variable "subnetList"{
  type = map(
    object({
       "subnetId" = string
       "typeList" = list(string)
    }) 
  )
  default = [
  {
    "subnetId" = (var.genomic-etl-subnet-1a-id)
    "typeList" = ["r5.2xlarge", "c5.2xlarge", "c5.4xlarge", "m5.2xlarge", "m5.4xlarge"]
  },
    {
    "subnetId" = (var.genomic-etl-subnet-1b-id)
    "typeList" = ["r5.2xlarge", "c5.2xlarge", "c5.4xlarge", "m5.2xlarge"]
  },
    {
    "subnetId" = (var.genomic-etl-subnet-1c-id)
    "typeList" = ["r5.2xlarge", "c5.2xlarge", "c5.4xlarge", "m5.2xlarge", "m5.4xlarge"]
  },
    {
    "subnetId" = (var.genomic-etl-subnet-1d-id)
    "typeList" = ["r5.2xlarge", "c5.2xlarge", "m5.2xlarge", "m5.4xlarge"]
  },
  {
    "subnetId" = (var.genomic-etl-subnet-1f-id)
    "typeList" = ["r5.2xlarge", "c5.2xlarge", "c5.4xlarge", "m5.2xlarge", "m5.4xlarge"]
  }]

}