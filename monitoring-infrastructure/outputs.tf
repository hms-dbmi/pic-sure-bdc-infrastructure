output "monitoring_security_group_id" {
  value = aws_security_group.monitoring.id
}

output "monitoring_instance_private_ip" {
  value = aws_instance.monitoring-ec2.private_ip
}

output "monitoring_instance_id" {
  value = aws_instance.monitoring-ec2.id
}
