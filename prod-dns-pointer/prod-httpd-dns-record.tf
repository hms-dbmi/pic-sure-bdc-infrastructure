
variable "target-stack" {
  description = "The stack identifier"
  type        = string
}

resource "aws_route53_record" "prod-httpd-dns-record" {
  zone_id = var.internal-dns-zone-id
  name    = "prod-httpd"
  type    = "CNAME"
  ttl     = "60"
  records = ["httpd.${var.target-stack}.datastage.hms.harvard.edu"]
}
