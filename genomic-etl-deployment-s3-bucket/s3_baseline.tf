
resource "aws_s3_bucket_object" "certs-folder" {
  bucket       = var.deployment_s3_bucket
  key          = "genomic-etl/certs/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "configs-folder" {
  bucket       = var.deployment_s3_bucket
  key          = "genomic-etl/configs/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "data-folder" {
  bucket       = var.deployment_s3_bucket
  key          = "genomic-etl/data/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "modules-folder" {
  bucket       = var.deployment_s3_bucket
  key          = "genomic-etl/modules/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "releases-folder" {
  bucket       = var.deployment_s3_bucket
  key          = "genomic-etl/releases/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "genomic-etl-tfstate-baseline" {
  bucket  = var.deployment_s3_bucket
  key     = "genomic-etl/deployment_state_metadata/terraform.tfstate"
  content = file("terraform.tfstate_baseline")
}

data "template_file" "genomic_etl_variables_template" {
  template = file("genomic_etl_variables.tf_template")
  vars = {
    deployment_s3_bucket = var.deployment_s3_bucket
  }
}

resource "aws_s3_bucket_object" "genomic-etl-variables-baseline" {
  bucket  = var.deployment_s3_bucket
  key     = "genomic-etl/deployment_state_metadata/genomic_etl_variables.tf"
  content = data.template_file.genomic_etl_variables_template.rendered
}

