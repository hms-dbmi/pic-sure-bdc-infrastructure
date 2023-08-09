### Inbound
resource "aws_security_group" "inbound-httpd-from-alb" {
  name        = "allow_inbound_from_public_subnet_to_httpd_${var.stack_githash}"
  description = "Allow inbound traffic from public subnets to httpd servers"
  vpc_id      = local.target_vpc

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.public_subnet_ids
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Name        = "inbound-from-public-internet Security Group - ${var.target_stack} - ${var.stack_githash}"
  }
}

resource "aws_security_group" "inbound-wildfly-from-httpd" {
  name        = "allow_inbound_from_httpd_subnet_${var.stack_githash}"
  description = "Allow inbound traffic from httpd to port 8080 on wildfly"
  vpc_id      = local.target_vpc

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    #cidr_blocks = local.private1_subnet_ids
    security_groups = [aws_security_group.inbound-httpd-from-alb.id]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Name        = "inbound-for-hpds Security Group - ${var.target_stack} - ${var.stack_githash}"
  }
}


resource "aws_security_group" "inbound-hpds-from-wildfly" {
  name        = "allow_inbound_from_private_subnet_to_hpds_${var.stack_githash}"
  description = "Allow inbound traffic from private-subnets on port 8080 for hpds"
  vpc_id      = local.target_vpc

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.inbound-wildfly-from-httpd.id]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Name        = "inbound-hpds Security Group - ${var.target_stack} - ${var.stack_githash}"
  }
}


resource "aws_security_group" "inbound-dictionary-from-wildfly" {
  name        = "allow_inbound_from_dictionary_to_hpds_${var.stack_githash}"
  description = "Allow inbound traffic from private-subnets on port 8080 for hpds"
  vpc_id      = local.target_vpc

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.inbound-wildfly-from-httpd.id]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Name        = "inbound-wildfly Security Group - ${var.target_stack} - ${var.stack_githash}"
  }
}


resource "aws_security_group" "inbound-mysql-from-wildfly" {
  name        = "allow_inbound_from_wildfly_to_mysql_${var.stack_githash}"
  description = "Allow inbound traffic from wildfly to mysql on port 3306"
  vpc_id      = local.target_vpc

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    #cidr_blocks = local.private2_subnet_ids
    security_groups = [aws_security_group.inbound-wildfly-from-httpd.id]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Name        = "inbound-mysql Security Group - ${var.target_stack} - ${var.stack_githash}"
  }
}


### Outbound
resource "aws_security_group" "outbound-to-internet" {
  name        = "allow_outbound_to_public_internet_${var.stack_githash}"
  description = "Allow outbound traffic to public internet"
  vpc_id      = local.target_vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Name        = "outbound-to-internet Security Group - ${var.target_stack} - ${var.stack_githash}"
  }
}
