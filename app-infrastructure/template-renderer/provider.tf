terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  version = ">= 4.0"
  region  = "us-east-1"
}
