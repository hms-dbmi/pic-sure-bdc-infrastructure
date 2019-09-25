resource "aws_security_group" "inbound-from-edge" {
  name = "allow_inbound_from_edge_private_subnet_to_app_vpc"
  description = "Allow inbound traffic from edge-private-subnets on port 8080 until we have TLS in place for app server"
  vpc_id = aws_vpc.app-vpc.id

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      aws_subnet.edge-public-subnet-us-east-1a.cidr_block, 
      aws_subnet.edge-public-subnet-us-east-1b.cidr_block, 
      aws_subnet.edge-public-subnet-us-east-1c.cidr_block
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - inbound-from-edge Security Group"
  }
}
resource "aws_security_group" "outbound-to-hpds" {
  name = "allow_outbound_from_app_vpc_to_hpds_port_in_data_vpc"
  description = "Allow outbound traffic to data-hpds-private-subnets on port 8080 until we have TLS in place for app server"
  vpc_id = aws_vpc.app-vpc.id

  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      aws_subnet.data-hpds-subnet-us-east-1a.cidr_block, 
      aws_subnet.data-hpds-subnet-us-east-1b.cidr_block, 
      aws_subnet.data-hpds-subnet-us-east-1c.cidr_block
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - outbound-to-hpds Security Group"
  }
}
resource "aws_security_group" "outbound-to-aurora" {
  name = "allow_outbound_from_app_vpc_to_mysql_port_in_data_vpc"
  description = "Allow outbound traffic to data-db-subnets on port 3306"
  vpc_id = aws_vpc.app-vpc.id

  egress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [
      aws_subnet.data-db-subnet-us-east-1a.cidr_block, 
      aws_subnet.data-db-subnet-us-east-1b.cidr_block, 
      aws_subnet.data-db-subnet-us-east-1c.cidr_block
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - outbound-to-aurora Security Group"
  }
}
