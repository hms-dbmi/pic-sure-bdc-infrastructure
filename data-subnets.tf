resource "aws_subnet" "data-hpds-subnet-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "172.17.2.0/26"
  vpc_id = aws_vpc.datastage-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - HPDS Subnet us-east-1a"
  }
}

resource "aws_subnet" "data-hpds-subnet-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "172.17.2.64/26"
  vpc_id = aws_vpc.datastage-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - HPDS Subnet us-east-1b"
  }
}

resource "aws_subnet" "data-hpds-subnet-us-east-1c" {
  availability_zone = "us-east-1c"
  cidr_block = "172.16.2.128/26"
  vpc_id = aws_vpc.datastage-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - HPDS Subnet us-east-1c"
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
    Name        = "FISMA Terraform Playground - DB Subnet Group"
  }
}

resource "aws_subnet" "data-db-subnet-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "172.16.3.0/26"
  vpc_id = aws_vpc.datastage-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - DB Subnet us-east-1a"
  }
}

resource "aws_subnet" "data-db-subnet-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "172.16.3.64/26"
  vpc_id = aws_vpc.datastage-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - DB Subnet us-east-1b"
  }
}

resource "aws_subnet" "data-db-subnet-us-east-1c" {
  availability_zone = "us-east-1c"
  cidr_block = "172.16.3.128/26"
  vpc_id = aws_vpc.datastage-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - DB Subnet us-east-1c"
  }
}

