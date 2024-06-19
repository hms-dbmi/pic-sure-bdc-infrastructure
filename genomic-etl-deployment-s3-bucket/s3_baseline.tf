

resource "aws_s3_bucket_object" "session-logs-folder" {
  bucket       = var.output_s3_bucket
  key          = join("", ["genomic-etl/deployment_state_metadata/",var.study_id, var.consent_group_tag, "/", var.chrom_number, "/var.session_logs/"])
  content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "genomic-etl-tfstate-baseline" {
  bucket  = var.output_s3_bucket
  key     = join("", ["genomic-etl/deployment_state_metadata/",var.study_id, var.consent_group_tag, "/", var.chrom_number, "/terraform.tfstate"])
  content = file("terraform.tfstate_baseline")
}

data "template_file" "genomic_etl_variables_template" {
  template = file("genomic_etl_variables.tf_template")
  vars = {
    output_s3_bucket = var.output_s3_bucket
    study_id = var.study_id
    consent_group_tag = var.consent_group_tag
    chrom_number=var.chrom_number
    freeze_number=var.freeze_number
  }
}

resource "aws_s3_bucket_object" "genomic-etl-variables-baseline" {
  bucket  = var.output_s3_bucket
  key     = join("", ["genomic-etl/deployment_state_metadata/",var.study_id, var.consent_group_tag, "/", var.chrom_number,"/genomic_etl_variables.tf"])
  content = data.template_file.genomic_etl_variables_template.rendered
}

