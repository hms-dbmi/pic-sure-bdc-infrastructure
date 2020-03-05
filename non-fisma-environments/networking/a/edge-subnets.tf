
resource "aws_subnet" "edge-subnet-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "172.${var.cidr_block_variation}.0.0/24"
  vpc_id = aws_vpc.datastage-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Description = "FISMA Terraform Playground - ${var.stack_githash} - Edge Subnet us-east-1a"
    Name = "Web-Subnet-AZ1"
  }
}

resource "aws_subnet" "edge-subnet-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "172.${var.cidr_block_variation}.0.1/24"
  vpc_id = aws_vpc.datastage-vpc.id
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Description = "FISMA Terraform Playground - ${var.stack_githash} - Edge Subnet us-east-1b"
    Name = "Web-Subnet-AZ2"
  }
}

