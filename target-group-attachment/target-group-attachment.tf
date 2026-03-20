# Doing a lookup for the staging environments target group and attach the http instance that is being deployed
# Use tags for Project and Stack to find correct target group to update

data "aws_lb_target_group" "tg_name" {
  # need to use name or arn with current provider
  name = local.tg_name
  # cannot use tags with current aws provider.
  # updating the provider broke other things
  # implement tags once provider can be updated to latest.
  #tags = {
  #  Project = local.project
  #  Stack	= local.lb_target_stack
  #}
}

# use the arn from data resource staging.
# use the instance-id for the httpd server < instance-id does not seem to work with current provider. Can use private ip.
# just saving this work tf file to explore issue with updating a tga via terraform causing the stack to be recreated.


# each stack gets attached to a single tg
# availability zone must be all to use vpcs out of scope of the alb.

resource "aws_lb_target_group_attachment" "stack_lb_tga" {
  target_group_arn  = data.aws_lb_target_group.tg_name.arn
  target_id         = aws_instance.httpd-ec2.private_ip
  port              = 443
  availability_zone = "all"
}

# used to promote the tga to the live target group.
# by default deployment should be always deploying to the staging environment.
# this should only be set to true when promoting staging to live.

variable "is_promote_tga" {
  type	  =	bool
  default = false
}

#### Remove these when moving to tags.  

variable "staging_tg_name" {
  type = string
}

variable "live_tg_name" {
  type = string
}

#####

# variable to handle if we are promoting  
# is_live tag to let us know if the stack is the live server or not.

locals {
  lb_target_stack = var.is_promote_tga ? var.env_live_subdomain : var.env_staging_subdomain
  is_live         = var.is_promote_tga ? true: false
  
  # for use to support not having tags remove when provider is updated
  tg_name         = var.is_promote_tga ? var.live_tg_name: var.staging_tg_name
  
}