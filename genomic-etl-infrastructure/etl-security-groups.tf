resource "aws_security_group" "traffic-to-ssm" {
  name = "allow_traffic_from_genomic_etl_to_ssm_${var.deployment_githash}_${var.study_id}${var.consent_group_tag}-${var.chrom_number} "
  description = "allows ec2 to communicate with amazon systems manager and allows for sessions manager use"
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
    Name        = "FISMA Terraform Playground - ${var.deployment_githash}_${var.study_id}${var.consent_group_tag}-${var.chrom_number}  - traffic-to-ssm Security Group"
  }
}

resource "aws_security_group" "outbound-to-public-internet" {
  name = "allow_outbound_to_public_internet_to_genomic_etl_${var.deployment_githash}_${var.study_id}${var.consent_group_tag}-${var.chrom_number} "
  description = "Allow outbound traffic from genomic servers to internet for download/installation purposes"
  vpc_id = var.target-vpc

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.deployment_githash}_${var.study_id}${var.consent_group_tag}-${var.chrom_number}  - outbound-to-public-internet Security Group"
   }
  }