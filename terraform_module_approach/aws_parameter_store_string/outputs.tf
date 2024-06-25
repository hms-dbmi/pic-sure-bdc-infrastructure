output "string_parameter_names" {
  value = [for k in aws_ssm_parameter.string_parameter : k.name]
}