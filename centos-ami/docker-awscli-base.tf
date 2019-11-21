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

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "134.174.0.0/16"
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - outbound-to-internet for AMI creation"
  }
}
resource "aws_iam_role_policy" "docker-awscli-base-policy" {
  name = "docker-awscli-base-policy"
  role = aws_iam_role.docker-awscli-base-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:CreateTags"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:*:*:instance/*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "docker-awscli-base-role" {
  name               = "docker-awscli-base-role"
  path               = "/system/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "docker-awscli-base-profile" {
  name = "docker-awscli-base-profile"
  roles = [aws_iam_role.docker-awscli-base-role.name]
}


resource "aws_instance" "docker-awscli-base" {
  ami = "ami-05091d5b01d0fda35"
  instance_type = "m5.large"
  key_name = "jenkins-provisioning-key"

  iam_instance_profile = aws_iam_instance_profile.docker-awscli-base-profile.name

  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 50
  }

  vpc_security_group_ids = [
    aws_security_group.outbound-to-internet.id
  ]
  subnet_id = var.edge-subnet-us-east-1a-id

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Docker AWS CLI AMI"
  }

  user_data = file("install_docker_and_awscli.sh")

}
