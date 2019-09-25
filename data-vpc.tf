resource "aws_vpc" "data-vpc" {
  cidr_block = "172.16.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Data VPC"
  }

}

resource "aws_subnet" "data-hpds-subnet-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "172.16.0.0/19"
  vpc_id = aws_vpc.data-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Data VPC Private HPDS Subnet us-east-1a"
  }
}

resource "aws_subnet" "data-hpds-subnet-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "172.16.32.0/19"
  vpc_id = aws_vpc.data-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Data VPC Private HPDS Subnet us-east-1b"
  }
}

resource "aws_subnet" "data-hpds-subnet-us-east-1c" {
  availability_zone = "us-east-1c"
  cidr_block = "172.16.64.0/19"
  vpc_id = aws_vpc.data-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Data VPC Private HPDS Subnet us-east-1c"
  }
}

resource "aws_db_subnet_group" "data-subnet-group" {
  name       = "main"
  subnet_ids = [
    aws_subnet.data-db-subnet-us-east-1a.id, 
    aws_subnet.data-db-subnet-us-east-1b.id, 
    aws_subnet.data-db-subnet-us-east-1c.id
  ]
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Data VPC DB Subnet Group"
  }
}

resource "aws_subnet" "data-db-subnet-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "172.16.96.0/19"
  vpc_id = aws_vpc.data-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Data VPC Private DB Subnet us-east-1a"
  }
}

resource "aws_subnet" "data-db-subnet-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "172.16.128.0/19"
  vpc_id = aws_vpc.data-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Data VPC Private DB Subnet us-east-1b"
  }
}

resource "aws_subnet" "data-db-subnet-us-east-1c" {
  availability_zone = "us-east-1c"
  cidr_block = "172.16.160.0/19"
  vpc_id = aws_vpc.data-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Data VPC Private DB Subnet us-east-1c"
  }
}

resource "aws_default_security_group" "data-default" {
  vpc_id = "${aws_vpc.data-vpc.id}"

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
