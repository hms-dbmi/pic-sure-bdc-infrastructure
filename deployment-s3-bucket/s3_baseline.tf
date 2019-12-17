
resource "aws_s3_bucket_object" "base-folder" {
    bucket  = var.stack_s3_bucket
    key     =  "certs/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "base-folder" {
    bucket  = var.stack_s3_bucket
    key     =  "configs/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "base-folder" {
    bucket  = var.stack_s3_bucket
    key     =  "data/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "base-folder" {
    bucket  = var.stack_s3_bucket
    key     =  "modules/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "base-folder" {
    bucket  = var.stack_s3_bucket
    key     =  "releases/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "tfstate-baseline-a" {
  bucket = var.stack_s3_bucket
  key    = "/deployment_state_metadata/a/terraform.tfstate"
  content = file("terraform.tfstate_baseline")
}

resource "aws_s3_bucket_object" "tfstate-baseline-b" {
  bucket = var.stack_s3_bucket
  key    = "/deployment_state_metadata/b/terraform.tfstate"
  content = file("terraform.tfstate_baseline")
}

resource "aws_s3_bucket_object" "tfstate-baseline-b" {
  bucket = var.stack_s3_bucket
  key    = "/deployment_state_metadata/stacks.json"
  content = file("stacks.json")
}

resource "aws_s3_bucket_object" "tfstate-baseline-b" {
  bucket = var.stack_s3_bucket
  key    = "/modules/mysql/mysql-connector-java-5.1.38.jar"
  content = file("mysql-connector-java-5.1.38.jar")
}

resource "aws_s3_bucket_object" "tfstate-baseline-b" {
  bucket = var.stack_s3_bucket
  key    = "/modules/mysql/module.xml"
  content = file("wildfly_mysql_module.xml")
}

resource "aws_s3_bucket_object" "tfstate-baseline-b" {
  bucket = var.stack_s3_bucket
  key    = "/certs/httpd/server.crt"
  content = file("httpd-server.crt")
}

resource "aws_s3_bucket_object" "tfstate-baseline-b" {
  bucket = var.stack_s3_bucket
  key    = "/certs/httpd/server.key"
  content = file("httpd-server.key")
}

resource "aws_s3_bucket_object" "tfstate-baseline-b" {
  bucket = var.stack_s3_bucket
  key    = "/certs/httpd/server.chain"
  content = file("httpd-server.chain")
}


