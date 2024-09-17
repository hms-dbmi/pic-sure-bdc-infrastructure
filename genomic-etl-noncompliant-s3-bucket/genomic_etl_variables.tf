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
  default = ""
}
variable "chrom_number"{
  type = string
  default = "CHROMOSOME_NUMBER"
}
variable "freeze_number"{
  type = string
  default = ""
}
variable "study_name"{
  type = string
  default = "STUDY_NAME"
}
variable "s3_role"{
  type = string
  default = "S3_ROLE"
}
