variable "secure_parameters" {
  description = "A map of secure parameters to create"
  type        = map(string)
}

variable "environment_name" {
  description = "The name of the environment"
  type        = string
}

variable "environment_prefix" {
  description = "The prefix of the environment"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}