output "httpd-ec2-id" {
  value = aws_instance.httpd-ec2.id
}

output "wildfly-ec2-id" {
  value = aws_instance.wildfly-ec2.id
}

output "dictionary-ec2-id" {
  value = aws_instance.dictionary-ec2.id
}

output "hpds-ec2-open-id" {
  value = local.open_hpds_instance_id
}

output "hpds-ec2-auth-id" {
  value = local.auth_hpds_instance_id
}

locals {
  open_hpds_instance_id = length(aws_instance.open-hpds-ec2) > 0 ? aws_instance.open-hpds-ec2[0].id : ""
  auth_hpds_instance_id = length(aws_instance.auth-hpds-ec2) > 0 ? aws_instance.auth-hpds-ec2[0].id : ""
}