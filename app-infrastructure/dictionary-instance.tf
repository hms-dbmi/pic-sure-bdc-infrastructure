data "template_file" "dictionary-user_data" {
  template = file("scripts/dictionary-user_data.sh")
  vars = {
    stack_githash   = var.stack_githash_long
    stack_s3_bucket = var.stack_s3_bucket
    target_stack    = var.target_stack
    gss_prefix      = "bdc_${var.env_is_open_access ? "open" : "auth"}_${var.environment_name}"
  }
}

data "template_cloudinit_config" "dictionary-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.dictionary-user_data.rendered
  }

}

resource "aws_instance" "dictionary-ec2" {
  ami = local.ami_id
  //TODO double check this value at runtime to check that performance not impacted
  instance_type = "m5.xlarge"

  subnet_id = local.private2_subnet_ids[0]

  iam_instance_profile = "dictionary-deployment-s3-profile-${var.target_stack}-${var.stack_githash}"

  user_data = data.template_cloudinit_config.dictionary-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.outbound-to-internet.id,
    aws_security_group.inbound-dictionary-from-wildfly.id,
  ]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 100
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Stack       = var.env_staging_subdomain
    Project     = local.project
    Name        = "Dictionary - ${var.target_stack} - ${var.stack_githash}"
  }

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }
}
