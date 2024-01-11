# TODO: Determine how we can move this out.
# We should move these conditional statements to the module composition layer.
variable "env_is_open_access" {
  description = "Is the environment open access?"
  type        = bool
}

variable "target_stack" {
  description = "Green stack to target for deployment"
  type        = string
}

variable "stack_s3_bucket" {
  description = "S3 bucket for deployments"
  type        = string
}

#variable "data_s3_object_key" {
#  description = "S3 key for deployments"
#  type        = string
#}
variable "gss_prefix" {
    description = "GSS prefix for deployments"
    type        = string
}

variable "stack_githash_long" {
  description = "In our applications this is used to in the S3 folder structure. Example: jenkins_pipeline_build_<git_hash_long>"
  type        = string
}

variable "dataset_s3_object_key" {
  description = "The s3 object key within the environment s3 bucket"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "outbound-to-internet-sg-id" {
  description = "Security group ID for the outbound to internet security group"
  type        = string
}

variable "inbound-httpd-from-alb-sg-id" {
  description = "Security group ID for the inbound from internet security group"
  type        = string
}

variable "tags_httpd_instance" {
  type        = map(string)
  description = "Tags to apply to the httpd instance"
}

variable "wildfly-ec2-private-ip" {
  description = "Private IP of the Wildfly EC2 instance"
  type        = string
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

#analytics_id                  = var.analytics_id,
#tag_manager_id                = var.tag_manager_id
#fence_client_id               = var.fence_client_id
#idp_provider                  = var.idp_provider
#idp_provider_uri              = var.idp_provider_uri
#application_id_for_base_query = var.application_id_for_base_query
#help_link                     = var.help_link
#login_link                    = var.login_link

variable "analytics_id" {
  type    = string
  default = "__ANALYTICS_ID__"
}

variable "tag_manager_id" {
  type    = string
  default = "__TAG_MANAGER_ID__"
}

variable "help_link" {
  type    = string
  default = "https://bdcatalyst.freshdesk.com/support/home"
}

variable "login_link" {
  type        = string
  description = "Relative or absolute URL to redirect to upon login"
  default     = "/psamaui/login/?redirection_url=/picsureui/"
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

variable "uniq_name" {
  type        = string
  description = "Unique name for the deployment to be appended to the end of the ec2 iam instance profile name"
}

variable "environment_name" {
  type        = string
  description = "Environment name for the deployment to be appended to the ec2 iam instance profile name"
}