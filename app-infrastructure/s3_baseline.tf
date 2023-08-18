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

resource "aws_s3_bucket_object" "mysql-connector-jar" {
  bucket         = var.stack_s3_bucket
  key            = "/modules/mysql/mysql-connector-java-5.1.38.jar"
  content_base64 = filebase64("mysql-connector-java-5.1.38.jar")
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_object" "mysql-module-xml" {
  bucket  = var.stack_s3_bucket
  key     = "/modules/mysql/module.xml"
  content = file("configs/wildfly_mysql_module.xml")
  lifecycle {
    prevent_destroy = true
  }
}
