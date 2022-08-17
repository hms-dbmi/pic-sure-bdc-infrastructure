resource "aws_security_group" "outbound-to-ssm" {
  name = "allow_outbound_from_genomic_etl_to_ssm_${var.deployment_githash}"
  description = "Allow outbound traffic to ssm without a public ip"
  vpc_id = var.target-vpc

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      var.genomic-etl-subnet-us-east-cidr
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.deployment_githash} - outbound-to-hpds Security Group"
  }
}

resource "aws_security_group" "inbound-app-from-lma-for-dev-only" {
  name = "allow_inbound_from_lma_subnet_to_app_server_${var.deployment_githash}"
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
    Name        = "FISMA Terraform Playground - ${var.deployment_githash} - inbound-app-from-lma-for-dev-only Security Group"
  }
}

resource "aws_security_group" "interal_app_traffic" {
  name = "allow_interal_app_traffic_${var.deployment_githash}"
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
    Name        = "FISMA Terraform Playground - ${var.deployment_githash} - internal app traffic Security Group"
  }
}