data "template_file" "wildfly-user_data" {
  template = file("scripts/wildfly-user_data.sh")
  vars     = {
    stack_githash         = var.stack_githash_long
    stack_s3_bucket       = var.stack_s3_bucket
    dataset_s3_object_key = var.dataset_s3_object_key
    target_stack          = var.target_stack
    gss_prefix            = "${var.environment_prefix}_${var.env_is_open_access ? "open" : "auth"}_${var.environment_name}"
    env_private_dns_name  = var.env_private_dns_name
  }
}

data "template_cloudinit_config" "wildfly-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.wildfly-user_data.rendered
  }
}

resource "aws_instance" "wildfly-ec2" {
  ami           = local.ami_id
  instance_type = "m7a.2xlarge"

  subnet_id = local.private2_subnet_ids[0]

  iam_instance_profile = "wildfly-deployment-profile-${var.target_stack}-${local.uniq_name}"

  user_data = data.template_cloudinit_config.wildfly-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.outbound-to-internet.id,
    aws_security_group.inbound-wildfly-from-httpd.id,
    aws_security_group.inbound-wildfly-from-hpds.id
  ]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 50
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Project     = local.project
    Stack       = var.target_stack
    Name        = "Wildfly - ${var.target_stack} - ${local.uniq_name}"
  }

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

}

