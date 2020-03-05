resource "aws_db_subnet_group" "data-subnet-group" {
  name       = "main-b"
  subnet_ids = [
    aws_subnet.db-subnet-us-east-1a.id, 
    aws_subnet.db-subnet-us-east-1b.id
  ]
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Description        = "FISMA Terraform Playground - ${var.stack_githash} - DB Subnet Group"
    Name = "main-b"
  }
}

resource "aws_subnet" "db-subnet-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "172.${var.cidr_block_variation}.30.0/24"
  vpc_id = aws_vpc.datastage-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Description = "FISMA Terraform Playground - ${var.stack_githash} - DB Subnet us-east-1a"
    Name = "Database-Subnet-AZ1"
  }
}

resource "aws_subnet" "db-subnet-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "172.${var.cidr_block_variation}.31.0/24"
  vpc_id = aws_vpc.datastage-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Description = "FISMA Terraform Playground - ${var.stack_githash} - DB Subnet us-east-1b"
    Name = "Database-Subnet-AZ2"
  }
}


