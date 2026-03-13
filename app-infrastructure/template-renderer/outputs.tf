output "hpds_auth_env_s3_key" {
  description = "S3 key of the rendered auth HPDS env file"
  value       = var.render_auth_hpds ? aws_s3_object.hpds_auth_env[0].key : ""
}

output "hpds_auth_env_etag" {
  description = "ETag of the rendered auth HPDS env file"
  value       = var.render_auth_hpds ? aws_s3_object.hpds_auth_env[0].etag : ""
}

output "hpds_open_env_s3_key" {
  description = "S3 key of the rendered open HPDS env file"
  value       = var.render_open_hpds ? aws_s3_object.hpds_open_env[0].key : ""
}

output "hpds_open_env_etag" {
  description = "ETag of the rendered open HPDS env file"
  value       = var.render_open_hpds ? aws_s3_object.hpds_open_env[0].etag : ""
}
