resource "aws_s3_object" "hpds_auth_env" {
  count = var.render_auth_hpds ? 1 : 0

  bucket = var.stack_s3_bucket
  key    = "configs/hpds/${var.target_stack}/auth-hpds.env"
  content = templatefile("${path.module}/templates/hpds-auth.env.tftpl", {
    environment_name     = var.environment_name
    target_stack         = var.target_stack
    env_private_dns_name = var.env_private_dns_name
  })

  content_type           = "text/plain"
  server_side_encryption = "AES256"
}

resource "aws_s3_object" "hpds_open_env" {
  count = var.render_open_hpds ? 1 : 0

  bucket  = var.stack_s3_bucket
  key     = "configs/hpds/${var.target_stack}/open-hpds.env"
  content = templatefile("${path.module}/templates/hpds-open.env.tftpl", {})

  content_type           = "text/plain"
  server_side_encryption = "AES256"
}
