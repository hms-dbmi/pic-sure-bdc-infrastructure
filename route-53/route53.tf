provider "aws" {
  region     = "us-east-1" 
  profile    = "avillachlab-secure-infrastructure"
}

resource "aws_route53_record" "wildfly" {
  zone_id = var.internal-dns-zone-id
  name    = "wildfly.${var.target-stack}"
  type    = "A"
  ttl     = "60"
  records = [var.wildfly-ec2-private_ip]
}

resource "aws_route53_record" "httpd" {
  zone_id = var.internal-dns-zone-id
  name    = "httpd.${var.target-stack}"
  type    = "A"
  ttl     = "60"
  records = [var.httpd-ec2-private_ip]
}

resource "aws_route53_record" "hpds" {
  zone_id = var.internal-dns-zone-id
  name    = "hpds.${var.target-stack}"
  type    = "A"
  ttl     = "60"
  records = [var.hpds-ec2-private_ip]
}

resource "aws_route53_record" "picsure-db" {
  zone_id = var.internal-dns-zone-id
  name    = "picsure-db.${var.target-stack}"
  type    = "CNAME"
  ttl     = "60"
  records = [var.pic-sure-mysql-address]
}

variable "target-stack" {
  description = "The stack identifier"
  type        = string
}