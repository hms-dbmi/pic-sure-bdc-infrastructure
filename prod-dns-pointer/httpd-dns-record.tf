
variable "target-prod-stack" {
  description = "The stack identifier to become the current prod"
  type        = string
}

variable "target-next-prod-stack" {
  description = "The stack identifier to become the next prod(or stage)"
  type        = string
}

resource "aws_route53_record" "prod-httpd-dns-record" {
  zone_id = var.internal-dns-zone-id
  name    = "prod-httpd"
  type    = "CNAME"
  ttl     = "60"
  records = ["httpd.${var.target-prod-stack}.${var.env_private_dns_name}"]
}

resource "aws_route53_record" "next-prod-httpd-dns-record" {
  zone_id = var.internal-dns-zone-id
  name    = "next-prod-httpd"
  type    = "CNAME"
  ttl     = "60"
  records = ["httpd.${var.target-next-prod-stack}.${var.env_private_dns_name}"]
}
