variable "output_s3_bucket"{
  type = string
  default = "__S3_BUCKET_FOR_FILE_OUTPUT__"
}
variable "study_id"{
  type = string
  default = "PHS_NUMBER_FOR STUDY"
}
variable "consent_group_tag"{
  type = string
  default = "CONSENT_GROUP_-1_IF_NONE"
}
variable "chrom_number"{
  type = string
  default = "CHROMOSOME_NUMBER"
}

