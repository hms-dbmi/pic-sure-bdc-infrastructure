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
  value = var.include_open_hpds ? aws_instance.auth-hpds-ec2[0].id : ""
}

output "hpds-ec2-auth-id" {
  value = var.include_auth_hpds ? aws_instance.open-hpds-ec2[0].id : ""
}
