module "httpd" {
  source                        = "../terraform_module_approach/httpd"
  ami_id                        = local.ami_id
  application_id_for_base_query = var.application_id_for_base_query
  dataset_s3_object_key         = var.dataset_s3_object_key
  env_is_open_access            = var.env_is_open_access
  env_private_dns_name          = var.env_private_dns_name
  env_public_dns_name           = var.env_public_dns_name
  env_public_dns_name_staging   = var.env_public_dns_name_staging
  environment_name              = var.environment_name
  gss_prefix                    = "${var.environment_prefix}_${var.env_is_open_access ? "open" : "auth"}_${var.environment_name}"
  inbound-httpd-from-alb-sg-id  = aws_security_group.inbound-httpd-from-alb.id
  outbound-to-internet-sg-id    = aws_security_group.outbound-to-internet.id
  stack_githash_long            = var.stack_githash_long
  stack_s3_bucket               = var.stack_s3_bucket
  subnet_id                     = local.private1_subnet_ids[0]
  tags_httpd_instance           = {
    Node        = "HTTPD"
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Stack       = var.target_stack
    Project     = local.project
    Name        = "Apache HTTPD - ${var.target_stack} - ${local.uniq_name}"
  }
  target_stack           = var.target_stack
  uniq_name              = local.uniq_name
  wildfly-ec2-private-ip = aws_instance.wildfly-ec2.private_ip
}