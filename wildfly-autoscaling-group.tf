resource "aws_launch_template" "wildfly-launch-template" {
  name_prefix = "wildfly"
  image_id = "ami-0ebb652e41c8f97fc"
  instance_type = "m5.large"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted = true
      volume_size = 20
    }
  }

  key_name = "jps49"
  
  vpc_security_group_ids = [
    aws_security_group.inbound-from-edge.id,
    aws_security_group.outbound-to-hpds.id,
    aws_security_group.outbound-to-aurora.id
  ]
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Wildfly Launch Template"
  }
  tag_specifications {
    resource_type = "instance" 
    tags = {
      Name = "WILDFLY"
    }
  }
}

resource "aws_autoscaling_group" "wildfly-autoscaling-group" {
  vpc_zone_identifier = [
    aws_subnet.app-private-subnet-us-east-1a.id,
    aws_subnet.app-private-subnet-us-east-1b.id,
    aws_subnet.app-private-subnet-us-east-1c.id
  ]

  desired_capacity = 1
  min_size = 1
  max_size = 1

  launch_template {
    id = aws_launch_template.wildfly-launch-template.id
  }

  tag {
    key = "Name"
    value = "Wildfly"
    propagate_at_launch = true
  }
}
