provider "aws" {
  region = "us-east-1" 
  profile = "avillachlab-secure-infrastructure"
  version = "3.74"
  
  assume_role {
    role_arn = "arn:aws:iam::${var.cnc_acct_id}:role/system/${var.jenkins_provisioning_assume_role_name}"
    duration = = "${var.jenkins_provisioning_assume_role_duration}"
    session_name = "Terraform"
  }
}
