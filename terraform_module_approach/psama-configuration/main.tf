# Parameters are expected to be the key value pairs of the parameters to be stored in the parameter store
# Example: "secure_parameter_name_1" = "secure_parameter_value_1", "secure_parameter_name_2" = "secure_parameter_value_2"

module "parameter_store_strings" {
  source     = "../aws_parameter_store_string"
  parameters = {}
  environment_name = var.environment_name
  environment_prefix = var.environment_prefix
  project_name = var.project_name
}

module "parameter_store_secure_strings" {
  source           = "../aws_parameter_store_secure_string"
  secure_parameters = {}
  environment_name = var.environment_name
  environment_prefix = var.environment_prefix
  project_name = var.project_name
}