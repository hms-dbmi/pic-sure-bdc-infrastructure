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

data "aws_vpc" "target_vpc" {
  filter {
    name   = "tag:Name"
    values = ["*-picsure-${var.environment_name}-${var.target_stack}-vpc"]
  }
  filter {
    name   = "tag:ApplicationName"
    values = [local.project]
  }
}

data "aws_vpc" "alb_vpc" {
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
    values = [local.alb_vpc]
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

# valid project values "Open PIC-SURE" : "Auth PIC-SURE"
# better off explicitly setting this so we can deploy any project's resources in an environment.
# won't be able to look up correct vpc tags otherwise
locals {
  ami_id               = data.aws_ami.this.id
  target_vpc           = data.aws_vpc.target_vpc.id
  alb_vpc              = data.aws_vpc.alb_vpc.id
  private1_subnet_ids  = data.aws_subnets.private1.ids
  private2_subnet_ids  = data.aws_subnets.private2.ids
  public_subnet_cidrs  = values(data.aws_subnet.public).*.cidr_block
  project              = var.env_project

  # db subnet group name needs to be more elastic
  # let's leverage the project variable to dynamically set set the requried name for now
  open_subnet_group_name = local.project == "Open PIC-SURE" ? "open-pic-sure-${var.environment_name}-${var.target_stack}": ""
  auth_subnet_group_name = local.project == "Auth PIC-SURE" ? "auth-pic-sure-${var.environment_name}-${var.target_stack}": ""
  picsure_subnet_group_name = local.project == "PIC-SURE" ? "pic-sure-${var.environment_name}-${var.target_stack}": ""
  db_subnet_group_name = coalesce(local.open_subnet_group_name, local.auth_subnet_group_name, local.picsure_subnet_group_name)

}
