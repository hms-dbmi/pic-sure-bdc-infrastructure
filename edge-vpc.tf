resource "aws_vpc" "edge-vpc" {
  cidr_block = "172.18.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Edge VPC"
  }

}

resource "aws_subnet" "edge-public-subnet-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "172.18.0.0/19"
  vpc_id = aws_vpc.edge-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Edge VPC Public Subnet us-east-1a"
  }
}

resource "aws_subnet" "edge-public-subnet-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "172.18.32.0/19"
  vpc_id = aws_vpc.edge-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Edge VPC Public Subnet us-east-1b"
  }
}

resource "aws_subnet" "edge-public-subnet-us-east-1c" {
  availability_zone = "us-east-1c"
  cidr_block = "172.18.64.0/19"
  vpc_id = aws_vpc.edge-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Edge VPC Public Subnet us-east-1c"
  }
}

resource "aws_default_security_group" "edge-default" {
  vpc_id = "${aws_vpc.edge-vpc.id}"

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

resource "aws_internet_gateway" "edge-gw" {
  vpc_id = aws_vpc.edge-vpc.id

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Edge VPC Internet Gateway"
  }  
}


