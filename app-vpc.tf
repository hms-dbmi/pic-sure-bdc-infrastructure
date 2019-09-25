resource "aws_vpc" "app-vpc" {
  cidr_block = "172.17.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Application VPC"
  }

}

resource "aws_subnet" "app-private-subnet-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "172.17.0.0/19"
  vpc_id = aws_vpc.app-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Application VPC Private Subnet us-east-1a"
  }
}

resource "aws_subnet" "app-private-subnet-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "172.17.32.0/19"
  vpc_id = aws_vpc.app-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Application VPC Private Subnet us-east-1b"
  }
}

resource "aws_subnet" "app-private-subnet-us-east-1c" {
  availability_zone = "us-east-1c"
  cidr_block = "172.17.64.0/19"
  vpc_id = aws_vpc.app-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Application VPC Private Subnet us-east-1c"
  }
}


resource "aws_default_security_group" "app-default" {
  vpc_id = "${aws_vpc.app-vpc.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - No Access Security Group"
  }
}
