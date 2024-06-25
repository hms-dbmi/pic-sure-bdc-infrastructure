output "secure_string_parameter_names" {
  value = [for k in aws_ssm_parameter.secure_string_parameter : k.name]
}