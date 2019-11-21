
data "template_file" "hpds-user_data" {
  template = file("scripts/hpds-user_data.sh")
  vars = {
    stack_githash = var.stack_githash_long
  }
}

data "template_cloudinit_config" "hpds-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.hpds-user_data.rendered
  }

}

resource "aws_launch_template" "hpds-launch-template" {
  depends_on = [
    aws_key_pair.generated_key
  ]
  name_prefix = "hpds"
  image_id = "ami-05091d5b01d0fda35"
  instance_type = "m5.large"
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted = true
      volume_size = 50
    }
  }

  key_name = aws_key_pair.generated_key.key_name
  user_data = data.template_cloudinit_config.hpds-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.inbound-hpds-from-app.id,
    aws_security_group.outbound-to-trend-micro.id
  ]
  iam_instance_profile {
    name = aws_iam_instance_profile.hpds-deployment-s3-profile.name
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - HPDS Launch Template"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "FISMA Terraform Playground - ${var.stack_githash} - HPDS"
    }
  }
}

resource "aws_autoscaling_group" "hpds-autoscaling-group" {
  vpc_zone_identifier = [
      var.db-subnet-us-east-1a-id, 
      var.db-subnet-us-east-1b-id
  ]

  desired_capacity = 1
  min_size = 1
  max_size = 1

  launch_template {
    id = aws_launch_template.hpds-launch-template.id
  }

  tag {
    key = "Name"
    value = "FISMA Terraform Playground - ${var.stack_githash} - HPDS"
    propagate_at_launch = true
  }
}
