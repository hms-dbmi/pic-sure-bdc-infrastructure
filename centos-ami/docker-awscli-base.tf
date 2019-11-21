
resource "aws_security_group" "inbound-app-from-lma-for-dev-only" {
  name = "allow_inbound_from_lma_subnet_to_app_server"
  description = "Allow inbound traffic from LMA on port 22"
  vpc_id = var.target-vpc

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - inbound-app-from-lma-for-dev-only Security Group"
  }
}

data "template_file" "docker-aws-cli-user_data" {
  template = file("install_docker_and_awscli.sh")
  vars = {
    stack_githash = var.stack_githash_long
  }
}

data "template_cloudinit_config" "docker-aws-cli-user_data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.docker-aws-cli-user_data.rendered
  }

}

resource "aws_launch_template" "docker-aws-cli-launch-template" {
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
  user_data = data.template_cloudinit_config.hpds-user_data.rendered

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