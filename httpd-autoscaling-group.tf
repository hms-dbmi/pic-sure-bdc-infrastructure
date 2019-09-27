resource "aws_launch_template" "httpd-launch-template" {
  name_prefix = "httpd"
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

  vpc_security_group_ids = [
    aws_security_group.inbound-from-public-internet.id,
    aws_security_group.outbound-to-app.id
  ]

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Apache HTTPD Launch Template"
  }
  tag_specifications {
    resource_type = "instance" 
    tags = {
      Name = "FISMA Terraform Playground - Apache HTTPD"
    }
  }
}

resource "aws_autoscaling_group" "httpd-autoscaling-group" {
  vpc_zone_identifier = [
    aws_subnet.edge-public-subnet-us-east-1a.id,
    aws_subnet.edge-public-subnet-us-east-1b.id,
    aws_subnet.edge-public-subnet-us-east-1c.id
  ]

  desired_capacity = 1
  min_size = 1
  max_size = 1

  launch_template {
    id = aws_launch_template.httpd-launch-template.id
  }

  tag {
    key = "Name"
    value = "FISMA Terraform Playground - Apache HTTPD"
    propagate_at_launch = true
  }
}
