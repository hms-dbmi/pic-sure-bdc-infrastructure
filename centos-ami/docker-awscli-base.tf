
resource "aws_security_group" "outbound-to-internet" {
  name = "outbound-to-internet"
  description = "Allow outbound traffic"
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
    Name        = "FISMA Terraform Playground - outbound-to-internet for AMI creation"
  }
}

data "template_file" "docker-aws-cli-user_data" {
  template = file("install_docker_and_awscli.sh")
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

resource "aws_instance" "docker-awscli-base" {
  ami = "ami-05091d5b01d0fda35"
  instance_type = "m5.large"
  key_name = "jenkins-provisioning-key"

  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 50
  }

  subnet_id = aws_subnet.jenkins-subnet-us-east-1a.id

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Docker AWS CLI AMI"
  }

  user_data = data.template_cloudinit_config.docker-aws-cli-user_data.rendered

}
