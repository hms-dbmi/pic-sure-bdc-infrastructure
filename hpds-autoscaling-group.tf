resource "aws_launch_template" "hpds-launch-template" {
  name_prefix = "hpds"
  image_id = "ami-0ebb652e41c8f97fc"
  instance_type = "m5.large"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted = true
      volume_size = 50
    }
  }

  key_name = "jps49"

  vpc_security_group_ids = [
    aws_security_group.inbound-hpds-from-app.id
  ]
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - HPDS Launch Template"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "HPDS"
    }
  }
}

resource "aws_autoscaling_group" "hpds-autoscaling-group" {
  vpc_zone_identifier = [
    aws_subnet.data-hpds-subnet-us-east-1a.id,
    aws_subnet.data-hpds-subnet-us-east-1b.id,
    aws_subnet.data-hpds-subnet-us-east-1c.id
  ]

  desired_capacity = 1
  min_size = 1
  max_size = 1

  launch_template {
    id = aws_launch_template.hpds-launch-template.id
  }

  tag {
    key = "Name"
    value = "HPDS"
    propagate_at_launch = true
  }
}
