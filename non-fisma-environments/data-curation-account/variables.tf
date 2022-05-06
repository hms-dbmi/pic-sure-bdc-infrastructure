variable "client-aws-account-role-arn" {
  type    = string
  default = "arn:aws:iam::281165049757:role/system/jenkins-s3-role"
}
variable "curated-transfer-s3-arn-path" {
  type    = string
  default = "arn:aws:s3:::avillach-73-bdcatalyst-etl/general/hpds/javabin/*"
}