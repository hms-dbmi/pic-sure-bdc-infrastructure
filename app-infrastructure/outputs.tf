output "httpd-ec2-id" {
  value = aws_instance.httpd-ec2.id
}

output "wildfly-ec2-id" {
  value = aws_instance.wildfly-ec2.id
}

output "dictionary-ec2-id" {
  value = aws_instance.dictionary-ec2.id
}

output "open-hpds-ec2-id" {
  value = one(aws_instance.open-hpds-ec2[*].id)
}

output "auth-hpds-ec2-id" {
  value = one(aws_instance.auth-hpds-ec2[*].id)
}
