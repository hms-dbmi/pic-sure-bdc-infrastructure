#Lookup latest AMI
data "aws_ami" "centos" {
  most_recent = true
  owners      = ["752463128620"]
  name_regex  = "^srce-centos7-golden-*"
}

data "aws_vpc" "target_vpc" {
  filter {
    name   = "tag:Name"
    values = ["*-picsure-${var.environment_name}-${var.target_stack}-vpc"]
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

data "aws_subnets" "private2" {
  filter {
    name   = "vpc-id"
    values = [local.target_vpc]
  }
  filter {
    name   = "tag:Name"
    values = ["*private2*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [local.target_vpc]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}


locals {
  ami_id              = data.aws_ami.centos.id
  target_vpc          = data.aws_vpc.target_vpc.id
  private1_subnet_ids = data.aws_subnets.private1.ids
  private2_subnet_ids = data.aws_subnets.private2.ids
  public_subnet_cidrs = values(data.aws_subnet.public).*.cidr_block
  project             = var.env_is_open_access ? "Open PIC-SURE" : "Auth PIC-SURE"
}
