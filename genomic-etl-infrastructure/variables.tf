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

variable "ami-id" {
  description = "AMI to use for all ec2s"
  type        = string
}

variable "environment_name" {
  description = "The name of the environment"
  type        = string
  default     = "picsure"
}