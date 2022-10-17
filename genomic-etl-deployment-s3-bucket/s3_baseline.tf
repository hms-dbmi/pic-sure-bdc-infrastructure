

resource "aws_s3_bucket_object" "session-logs-folder" {
  bucket       = var.deployment_s3_bucket
  key          = "genomic-etl/session_logs/"
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

