data "template_file" "auth_hpds-user_data" {
  template = file("scripts/auth_hpds-user_data.sh")
  vars = {
    stack_githash                 = var.stack_githash_long
    dataset_s3_object_key         = var.dataset_s3_object_key
    genomic_dataset_s3_object_key = var.genomic_dataset_s3_object_key
    stack_s3_bucket               = var.stack_s3_bucket
    target_stack                  = var.target_stack
  }
}

data "template_cloudinit_config" "auth_hpds-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.auth_hpds-user_data.rendered
  }

}

resource "aws_instance" "auth-hpds-ec2" {
  count = var.env_is_open_access ? 0 : 1

  ami           = local.ami_id
  instance_type = "m5.12xlarge"

  subnet_id = local.private2_subnet_ids[0]

  iam_instance_profile = "auth-hpds-deployment-s3-profile-${var.target_stack}-${var.stack_githash}"

  user_data = data.template_cloudinit_config.auth_hpds-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.outbound-to-internet.id,
    aws_security_group.inbound-hpds-from-wildfly.id,
  ]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 1000
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Stack       = var.env_staging_subdomain
    Project     = local.project
    Name        = "${var.stack_githash} - Auth HPDS - ${var.target_stack}"
  }

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }
}

