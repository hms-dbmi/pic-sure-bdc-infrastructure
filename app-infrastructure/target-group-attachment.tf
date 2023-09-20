# Doing a lookup for the staging environments target group and attach the http instance that is being deployed
# Use tags for Project and Stack to find correct target group to update

data "aws_lb_target_group" "lb_tg_data" {
  # need to use name or arn with current provider
  name = local.alb_name
  # cannot use tags with current aws provider.
  # updating the provider broke other things
  # implement tags once provider can be updated to latest.
  #tags = {
  #  Project = local.project
  #  Stack	= local.lb_target_stack
  #}
}

# use the arn from data resource staging.
# use the instance-id for the httpd server
# each stack gets attached to a single tg

resource "aws_lb_target_group_attachment" "stack_lb_tga" {
  target_group_arn  = data.aws_lb_target_group.lb_tg_data.arn
  target_id         = aws_instance.httpd-ec2.id
  port              = 443
  availability_zone = "all"
}

# used to promote the tga to the live target group.
# by default deployment should be always deploying to the staging environment.
# this should only be set to true when promoting staging to live.
variable "is_promote_lb_tg" {
  type	  =	bool
  default = false
}

#### Remove these when moving to tags.  
variable "staging_lb_name" {
  type = string
}
variable "live_lb_name" {
  type = string
}

#####

# variable to handle if we are promoting  
# is_live tag to let us know if the stack is the live server or not.

locals {
  lb_target_stack = var.is_promote_lb_tg ? var.env_live_subdomain : var.env_staging_subdomain
  is_live         = var.is_promote_lb_tg ? true: false
  
  # for use to support not having tags remove when provider is updated
  alb_name        = var.is_promote_lb_tg ? var.live_lb_name: var.staging_lb_name
  
}