data "template_file" "monitoring-user_data" {
  template = file("scripts/monitoring-user_data.sh")
  vars = {
    stack_s3_bucket  = var.stack_s3_bucket
    environment_name = var.environment_name
    gss_prefix       = "${var.environment_prefix}_${var.env_is_open_access ? "open" : "auth"}_${var.environment_name}"
  }
}

data "template_cloudinit_config" "monitoring-user-data" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.monitoring-user_data.rendered
  }
}

resource "aws_instance" "monitoring-ec2" {
  ami           = local.ami_id
  instance_type = var.monitoring_instance_type

  subnet_id            = local.private1_subnet_ids[0]
  iam_instance_profile = aws_iam_instance_profile.monitoring.name
  user_data            = data.template_cloudinit_config.monitoring-user-data.rendered

  vpc_security_group_ids = [aws_security_group.monitoring.id]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = var.monitoring_volume_size_gb
  }

  tags = {
    Node        = "MONITORING"
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Project     = local.project
    Name        = "Monitoring - ${local.uniq_name}"
  }

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }
}
