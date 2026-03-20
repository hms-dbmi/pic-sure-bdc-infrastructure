# DNS RECORDS for all nodes
resource "aws_route53_record" "httpd-addr-record" {
  zone_id = var.env_hosted_zone_id
  name    = "httpd.${var.target_stack}.${var.env_private_dns_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.httpd-ec2.private_ip]
}

resource "aws_route53_record" "wildfly-addr-record" {
  zone_id = var.env_hosted_zone_id
  name    = "wildfly.${var.target_stack}.${var.env_private_dns_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.wildfly-ec2.private_ip]
}

resource "aws_route53_record" "open-hpds-addr-record" {
  count   = var.include_open_hpds ? 1 : 0
  zone_id = var.env_hosted_zone_id
  name    = "open-hpds.${var.target_stack}.${var.env_private_dns_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.open-hpds-ec2[0].private_ip]
}

resource "aws_route53_record" "auth-hpds-addr-record" {
  count   = var.include_auth_hpds ? 1 : 0
  zone_id = var.env_hosted_zone_id
  name    = "auth-hpds.${var.target_stack}.${var.env_private_dns_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.auth-hpds-ec2[0].private_ip]
}

resource "aws_route53_record" "dictionary-addr-record" {
  zone_id = var.env_hosted_zone_id
  name    = "dictionary.${var.target_stack}.${var.env_private_dns_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.dictionary-ec2.private_ip]
}