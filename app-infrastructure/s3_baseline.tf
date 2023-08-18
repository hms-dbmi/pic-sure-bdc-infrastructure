resource "aws_s3_bucket_object" "certs-folder" {
  bucket       = var.stack_s3_bucket
  key          = "certs/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "configs-folder" {
  bucket       = var.stack_s3_bucket
  key          = "configs/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "data-folder" {
  bucket       = var.stack_s3_bucket
  key          = "data/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "modules-folder" {
  bucket       = var.stack_s3_bucket
  key          = "modules/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "releases-folder" {
  bucket       = var.stack_s3_bucket
  key          = "releases/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "stacks-json" {
  bucket                        = var.stack_s3_bucket
  key                           = "/deployment_state_metadata/stacks.json"
  object_lock_legal_hold_status = "OFF"
  content                       = file("configs/stacks.json")
}

resource "aws_s3_bucket_object" "mysql-connector-jar" {
  bucket         = var.stack_s3_bucket
  key            = "/modules/mysql/mysql-connector-java-5.1.38.jar"
  content_base64 = filebase64("mysql-connector-java-5.1.38.jar")
}

resource "aws_s3_bucket_object" "mysql-module-xml" {
  bucket  = var.stack_s3_bucket
  key     = "/modules/mysql/module.xml"
  content = file("configs/wildfly_mysql_module.xml")
}
