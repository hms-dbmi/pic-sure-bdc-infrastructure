
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

resource "aws_s3_bucket_object" "tfstate-baseline-a" {
  bucket  = var.stack_s3_bucket
  key     = "/deployment_state_metadata/a/terraform.tfstate"
  content = file("terraform.tfstate_baseline")
}

resource "aws_s3_bucket_object" "tfstate-baseline-b" {
  bucket  = var.stack_s3_bucket
  key     = "/deployment_state_metadata/b/terraform.tfstate"
  content = file("terraform.tfstate_baseline")
}

resource "random_password" "picsure-client-secret" {
  length = 32
  special = false
}

data "template_file" "stack_variables_template" {
  template = file("stack_variables.tf_template")
  vars = {
    picsure_client_secret = random_password.picsure-client-secret.result
    stack_s3_bucket = var.stack_s3_bucket
  }
}

resource "aws_s3_bucket_object" "stack-variables-baseline-a" {
  bucket  = var.stack_s3_bucket
  key     = "/deployment_state_metadata/a/stack_variables.tf"
  content = data.template_file.stack_variables_template.rendered
}

resource "aws_s3_bucket_object" "stack-variables-baseline-b" {
  bucket  = var.stack_s3_bucket
  key     = "/deployment_state_metadata/b/stack_variables.tf"
  content = data.template_file.stack_variables_template.rendered
}

resource "aws_s3_bucket_object" "stacks-json" {
  bucket                        = var.stack_s3_bucket
  key                           = "/deployment_state_metadata/stacks.json"
  object_lock_legal_hold_status = "OFF"
  content                       = file("stacks.json")
}

resource "aws_s3_bucket_object" "mysql-connector-jar" {
  bucket         = var.stack_s3_bucket
  key            = "/modules/mysql/mysql-connector-java-5.1.38.jar"
  content_base64 = filebase64("mysql-connector-java-5.1.38.jar")
}

resource "aws_s3_bucket_object" "mysql-module-xml" {
  bucket  = var.stack_s3_bucket
  key     = "/modules/mysql/module.xml"
  content = file("wildfly_mysql_module.xml")
}

resource "aws_s3_bucket_object" "server-cert" {
  bucket  = var.stack_s3_bucket
  key     = "/certs/httpd/server.crt"
  content = file("server.crt")
}

resource "aws_s3_bucket_object" "server-key" {
  bucket  = var.stack_s3_bucket
  key     = "/certs/httpd/server.key"
  content = file("server.key")
}

resource "aws_s3_bucket_object" "server-chain" {
  bucket  = var.stack_s3_bucket
  key     = "/certs/httpd/server.chain"
  content = file("server.chain")
}
