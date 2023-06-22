
# this needs to be refactored.
# should just make the route53 changes in terraform
# instead of outputting this file and using jenkins + aws / cli in the Teardown and Rebuild job to make the record changes. Yikes!!
data "template_file" "route53-ip-vars" {
  template = file("route53-variables.template")
  vars = {
    pic-sure-mysql-address            = aws_db_instance.pic-sure-mysql.address
    wildfly-ec2-private_ip            = aws_instance.wildfly-ec2.private_ip
    httpd-ec2-private_ip              = aws_instance.httpd-ec2.private_ip
    open-hpds-ec2-private_ip          = aws_instance.open-hpds-ec2.private_ip
    auth-hpds-ec2-private_ip          = aws_instance.auth-hpds-ec2.private_ip
    dictionary-ec2-private_ip         = aws_instance.dictionary-ec2.private_ip
  }
}

resource "local_file" "route53-ip-vars-file" {
    content = data.template_file.route53-ip-vars.rendered
    filename = "ip-vars.properties"
}

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
  zone_id = var.env_hosted_zone_id
  name    = "open-hpds.${var.target_stack}.${var.env_private_dns_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.open-hpds-ec2.private_ip]
}

resource "aws_route53_record" "auth-hpds-addr-record" {
  zone_id = var.env_hosted_zone_id
  name    = "auth-hpds.${var.target_stack}.${var.env_private_dns_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.auth-hpds-ec2.private_ip]
}

resource "aws_route53_record" "dictionary-addr-record" {
  zone_id = var.env_hosted_zone_id
  name    = "dictionary.${var.target_stack}.${var.env_private_dns_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.dictionary-ec2.private_ip]
}

resource "aws_route53_record" "picsure-db-cname-record" {
  zone_id = var.env_hosted_zone_id
  name    = "picsure-db.${var.target_stack}.${var.env_private_dns_name}"
  type    = "CNAME"
  ttl     = 60
  records = [aws_db_instance.pic-sure-mysql.address]
}