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
    ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "172.34.0.0/16"
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.deployment_githash} - outbound-to-hpds Security Group"
  }
}

resource "aws_security_group" "inbound-from-public-internet" {
  name = "allow_inbound_from_public_internet_to_genomic_etl_${var.deployment_githash}"
  description = "Allow inbound traffic from public internet to genomic servers for installation purposes"
  vpc_id = var.target-vpc

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.deployment_githash} - inbound-from-public-internet Security Group - ${var.target-stack}"
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