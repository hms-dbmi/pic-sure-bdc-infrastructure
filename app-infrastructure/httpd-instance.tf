data "template_file" "httpd-user_data" {
  template = file("scripts/httpd-user_data.sh")
  vars = {
    stack_githash         = var.stack_githash_long
    stack_s3_bucket       = var.stack_s3_bucket
    dataset_s3_object_key = var.dataset_s3_object_key
    target_stack          = var.target_stack
    gss_prefix            = "bdc_${var.env_is_open_access ? "open" : "auth"}_${var.environment_name}"
  }
}

data "template_cloudinit_config" "httpd-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.httpd-user_data.rendered
  }

}

resource "aws_instance" "httpd-ec2" {
  ami           = local.ami_id
  instance_type = "m5.large"

  subnet_id = local.private1_subnet_ids[0]

  iam_instance_profile = "httpd-deployment-s3-profile-${var.target_stack}-${var.stack_githash}"

  user_data = data.template_cloudinit_config.httpd-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.outbound-to-internet.id,
    aws_security_group.inbound-httpd-from-alb.id,
  ]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 50
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Stack       = var.env_staging_subdomain
    Project     = local.project
    Name        = "Apache HTTPD - ${var.target_stack} - ${var.stack_githash}"
  }

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

}

data "template_file" "httpd-vhosts-conf" {
  template = file("configs/httpd-vhosts.conf")
  vars = {

    wildfly-base-url = "http://${aws_instance.wildfly-ec2.private_ip}:8080"
    target_stack = var.target_stack
    release-id = var.stack_githash_long
    env_private_dns_name = var.env_private_dns_name
    env_public_dns_name  = var.env_public_dns_name
  }
}

resource "local_file" "httpd-vhosts-conf-file" {
  content  = data.template_file.httpd-vhosts-conf.rendered
  filename = "httpd-vhosts.conf"
}


data "template_file" "picsureui_settings" {
  template = file("configs/picsureui_settings.json")
  vars = {
    analytics_id                  = var.analytics_id,
    fence_client_id               = var.fence_client_id
    idp_provider                  = var.idp_provider
    idp_provider_uri              = var.idp_provider_uri
    application_id_for_base_query = var.application_id_for_base_query
  }
}

resource "local_file" "picsureui-settings-json" {
  content  = data.template_file.picsureui_settings.rendered
  filename = "picsureui-settings.json"
}
