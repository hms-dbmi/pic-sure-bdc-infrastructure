resource "aws_security_group" "inbound-hpds-from-app" {
  name = "allow_inbound_from_app_private_subnet_to_hpds"
  description = "Allow inbound traffic from app-private-subnets on port 8080 until we have TLS in place for hpds server"
  vpc_id = aws_vpc.data-vpc.id

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      aws_subnet.app-private-subnet-us-east-1a.cidr_block, 
      aws_subnet.app-private-subnet-us-east-1b.cidr_block, 
      aws_subnet.app-private-subnet-us-east-1c.cidr_block
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - inbound-hpds-from-app Security Group"
  }
}
resource "aws_security_group" "inbound-mysql-from-app" {
  name = "allow_inbound_from_app_private_subnet_to_mysql"
  description = "Allow inbound traffic from app-private-subnets on port 3306"
  vpc_id = aws_vpc.data-vpc.id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [
      aws_subnet.app-private-subnet-us-east-1a.cidr_block, 
      aws_subnet.app-private-subnet-us-east-1b.cidr_block, 
      aws_subnet.app-private-subnet-us-east-1c.cidr_block
    ]
  }
  
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - inbound-mysql-from-app Security Group"
  }
}

