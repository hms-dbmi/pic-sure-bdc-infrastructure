provider "aws" {
  region  = "us-east-1"
  profile = "avillachlab-secure-infrastructure"
  version = "3.74"
}

resource "aws_ssm_parameter" "string_parameter" {
  for_each = var.parameters

  name  = "/${var.project_name}_${var.environment_prefix}/${var.environment_name}/${each.key}"
  type  = "String"
  value = each.value
}