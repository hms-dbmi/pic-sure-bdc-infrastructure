provider "aws" {
  region     = "us-east-1" 
  profile    = "avillachlab-secure-infrastructure"
}

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

resource "aws_instance" "docker-awscli-base" {
  ami = "ami-05091d5b01d0fda35"
  instance_type = "m5.large"
  key_name = "jenkins-provisioning-key"

  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 50
  }

  subnet_id = var.edge-subnet-us-east-1a-id

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Docker AWS CLI AMI"
  }

  user_data = file("install_docker_and_awscli.sh")

}
