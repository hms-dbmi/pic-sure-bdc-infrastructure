resource "aws_security_group" "traffic-to-ssm" {
  name = "allow_traffic_from_genomic_etl_to_ssm_${var.deployment_githash}"
  description = "Allow traffic to ssm without a public ip"
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
    Name        = "FISMA Terraform Playground - ${var.deployment_githash} - traffic-to-ssm Security Group"
  }
}
}