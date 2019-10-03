resource "aws_vpc" "datastage-vpc" {
  cidr_block = "172.17.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - DataStage VPC"
  }

}

resource "aws_default_security_group" "data-default" {
  vpc_id = aws_vpc.datastage-vpc.id

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

resource "aws_internet_gateway" "inet-gw" {
  vpc_id = aws_vpc.datastage-vpc.id

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - DataSTAGE Internet Gateway"
  }  
}