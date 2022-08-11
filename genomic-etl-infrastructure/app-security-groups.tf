resource "aws_security_group" "inbound-from-edge" {
  name = "allow_inbound_from_edge_subnet_to_app_subnet_${var.stack_githash}"
  description = "Allow inbound traffic from edge-private-subnets on port 8080 until we have TLS in place for app server"
  vpc_id = var.target-vpc

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      var.edge-subnet-us-east-1a-cidr, 
      var.edge-subnet-us-east-1b-cidr
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - inbound-from-edge Security Group - ${var.target-stack}"
  }
}
resource "aws_security_group" "outbound-to-hpds" {
  name = "allow_outbound_from_app_subnets_to_hpds_port_in_hpds_subnets_${var.stack_githash}"
  description = "Allow outbound traffic to data-hpds-subnets on port 8080 until we have TLS in place for app server"
  vpc_id = var.target-vpc

  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      var.db-subnet-us-east-1a-cidr, 
      var.db-subnet-us-east-1b-cidr
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - outbound-to-hpds Security Group - ${var.target-stack}"
  }
}

resource "aws_security_group" "inbound-app-from-lma-for-dev-only" {
  name = "allow_inbound_from_lma_subnet_to_app_server_${var.stack_githash}"
  description = "Allow inbound traffic from LMA on port 22"
  vpc_id = var.target-vpc

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "134.174.0.0/16","172.24.0.68/32"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - inbound-app-from-lma-for-dev-only Security Group - ${var.target-stack}"
  }
}

resource "aws_security_group" "outbound-to-aurora" {
  name = "allow_outbound_from_app_subneets_to_mysql_port_in_db_subnets_${var.stack_githash}"
  description = "Allow outbound traffic to data-db-subnets on port 3306"
  vpc_id = var.target-vpc

  egress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [
      var.db-subnet-us-east-1a-cidr, 
      var.db-subnet-us-east-1b-cidr
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - outbound-to-aurora Security Group - ${var.target-stack}"
  }
}

resource "aws_security_group" "interal_app_traffic" {
  name = "allow_interal_app_traffic_${var.stack_githash}"
  description = "Allow internal app traffic on port 8080"
  vpc_id = var.target-vpc

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    self = true
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - internal app traffic Security Group - ${var.target-stack}"
  }
}