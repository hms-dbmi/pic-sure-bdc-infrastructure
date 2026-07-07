#Lookup latest AMI
data "aws_ami" "this" {
  most_recent = true
  owners      = ["752463128620"]
  name_regex  = "^srce-rhel9-golden-*"
}

# Random string to use for dynamic names.
# use to get rid of git_hash in names causes conflicts if different env use same release controls
resource "random_string" "random" {
  length  = 6
  special = false
}
locals {
  uniq_name = random_string.random.result
}

# Monitoring is applied once per environment and survives blue/green stack
# swaps, so (unlike app-infrastructure) it has no var.target_stack to key off
# of. It is placed in the environment's shared "-a-" VPC, mirroring the
# app-infrastructure alb_vpc lookup which is likewise stack-independent.
data "aws_vpc" "target_vpc" {
  filter {
    name   = "tag:Name"
    values = ["*-picsure-${var.environment_name}-a-vpc"]
  }
  filter {
    name   = "tag:ApplicationName"
    values = [local.project]
  }
}

data "aws_subnets" "private1" {
  filter {
    name   = "vpc-id"
    values = [local.target_vpc]
  }
  filter {
    name   = "tag:Name"
    values = ["*private1*"]
  }
}

locals {
  ami_id              = data.aws_ami.this.id
  target_vpc          = data.aws_vpc.target_vpc.id
  private1_subnet_ids = data.aws_subnets.private1.ids
  project             = var.env_project
}
