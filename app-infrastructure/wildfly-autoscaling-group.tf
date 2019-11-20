resource "tls_private_key" "development-only-app-server-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
output "provisioning-private-key" {
  value = tls_private_key.development-only-app-server-key.private_key_pem
}
resource "aws_key_pair" "generated_key" {
  key_name   = "development-only-app-server-key"
  public_key = tls_private_key.development-only-app-server-key.public_key_openssh
}

data "template_cloudinit_config" "wildfly-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = replace(file("wildfly-scripts/wildfly-user_data.sh"), "stack_githash", var.stack_githash)
  }

}

resource "aws_launch_template" "wildfly-launch-template" {
  name_prefix = "wildfly"
  image_id = "ami-05091d5b01d0fda35"
  instance_type = "m5.large"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted = true
      volume_size = 30
    }
  }

  user_data = data.template_cloudinit_config.wildfly-user-data.rendered

  iam_instance_profile {
    name = aws_iam_instance_profile.wildfly-deployment-s3-profile.name
  }
  key_name = aws_key_pair.generated_key.key_name
  
  vpc_security_group_ids = [
    aws_security_group.inbound-from-edge.id,
    aws_security_group.outbound-to-hpds.id,
    aws_security_group.outbound-to-aurora.id,
    aws_security_group.inbound-app-from-lma-for-dev-only.id,
    aws_security_group.outbound-to-trend-micro.id
  ]
  
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - Wildfly Launch Template"
  }
  tag_specifications {
    resource_type = "instance" 
    tags = {
      Name = "FISMA Terraform Playground - ${var.stack_githash} - Wildfly"
    }
  }
}

resource "aws_autoscaling_group" "wildfly-autoscaling-group" {
  depends_on = [aws_rds_cluster_instance.aurora-cluster-instance]
  vpc_zone_identifier = [
      var.app-subnet-us-east-1a-id, 
      var.app-subnet-us-east-1b-id
  ]

  desired_capacity = 1
  min_size = 1
  max_size = 1

  launch_template {
    id = aws_launch_template.wildfly-launch-template.id
  }

  tag {
    key = "Name"
    value = "FISMA Terraform Playground - ${var.stack_githash} - Wildfly"
    propagate_at_launch = true
  }
}
