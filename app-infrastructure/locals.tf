#Lookup latest AMI
data "aws_ami" "centos" {
  most_recent = true
  owners      = ["752463128620"]
  name_regex  = "^srce-centos7-golden-*"
}

data "aws_vpc" "target_vpc" {
  filter {
    name = "tag:Name"
    values = ["*-picsure-${var.environment_name}-${var.target_stack}-vpc"]
  }
}

data "aws_subnet" "private1" {
  vpc_id = local.target_vpc
  filter {
    name   = "tag:Name"
    values = ["*private1*"]
  }
}

data "aws_subnet" "private2" {
  vpc_id = local.target_vpc
  filter {
    name   = "tag:Name"
    values = ["*private2*"]
  }
}

data "aws_subnet" "public" {
  vpc_id = local.target_vpc
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}


locals {
  ami_id              = data.aws_ami.centos.id
  target_vpc = data.aws_vpc.target_vpc[0].id
  private1_subnet_ids = data.aws_subnet.private1[*].id
  private2_subnet_ids = data.aws_subnet.private2[*].id
  public_subnet_ids   = data.aws_subnet.public[*].id
}
