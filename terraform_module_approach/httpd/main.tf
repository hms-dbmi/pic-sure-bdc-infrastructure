resource "aws_instance" "httpd-ec2" {
  ami           = var.ami_id
  instance_type = "m5.large"

  subnet_id            = var.subnet_id
  iam_instance_profile = "httpd-deployment-s3-profile-${var.target_stack}-${var.uniq_name}"
  user_data            = data.template_cloudinit_config.httpd-user-data.rendered

  vpc_security_group_ids = [
    var.outbound-to-internet-sg-id,
    var.inbound-httpd-from-alb-sg-id,
  ]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 50
  }

  tags = var.tags_httpd_instance

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

}
data "template_file" "httpd-user_data" {
  template = file("${path.module}/templates/httpd-user_data.sh")
  vars     = {
    stack_githash         = var.stack_githash_long
    stack_s3_bucket       = var.stack_s3_bucket
    dataset_s3_object_key = var.dataset_s3_object_key
    target_stack          = var.target_stack
    gss_prefix            = var.gss_prefix
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

data "template_file" "httpd-vhosts-conf" {
  template = file("${path.module}/templates/httpd-vhosts.conf")
  vars     = {

    wildfly-base-url            = "http://${var.wildfly-ec2-private-ip}:8080"
    target_stack                = var.target_stack
    release-id                  = var.stack_githash_long
    env_private_dns_name        = var.env_private_dns_name
    env_public_dns_name         = var.env_public_dns_name
    env_public_dns_name_staging = var.env_public_dns_name_staging
  }
}

resource "local_file" "httpd-vhosts-conf-file" {
  content  = data.template_file.httpd-vhosts-conf.rendered
  filename = "httpd-vhosts.conf"
}


data "template_file" "picsureui_settings" {
  template = file("${path.module}/templates/picsureui_settings.json")
  vars     = {
    analytics_id                  = var.analytics_id,
    tag_manager_id                = var.tag_manager_id
    fence_client_id               = var.fence_client_id
    idp_provider                  = var.idp_provider
    idp_provider_uri              = var.idp_provider_uri
    application_id_for_base_query = var.application_id_for_base_query
    help_link                     = var.help_link
    login_link                    = var.login_link
  }
}

resource "local_file" "picsureui-settings-json" {
  content  = data.template_file.picsureui_settings.rendered
  filename = "picsureui-settings.json"
}
