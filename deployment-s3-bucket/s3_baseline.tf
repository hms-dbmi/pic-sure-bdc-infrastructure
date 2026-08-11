resource "aws_s3_bucket_object" "certs-folder" {
  bucket       = var.stack_s3_bucket
  key          = "certs/"
  content_type = "application/x-directory"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_object" "configs-folder" {
  bucket       = var.stack_s3_bucket
  key          = "configs/"
  content_type = "application/x-directory"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_object" "data-folder" {
  bucket       = var.stack_s3_bucket
  key          = "data/"
  content_type = "application/x-directory"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_object" "modules-folder" {
  bucket       = var.stack_s3_bucket
  key          = "modules/"
  content_type = "application/x-directory"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_object" "releases-folder" {
  bucket       = var.stack_s3_bucket
  key          = "releases/"
  content_type = "application/x-directory"
  lifecycle {
    prevent_destroy = true
  }
}
