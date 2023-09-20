# Doing a lookup for the staging environments target group and attach the http instance that is being deployed
# Use tags for Project and Stack to find correct target group to update
data "aws_lb_target_group" "staging" {
  filter = {
    name = "tag:Project"
    values = [ local.project ]
  }
  filter = {
    name = "tag:Stack"
    values = [ var.lb_target_stack ]
  }
}

# use the arn from data resource staging.
# use the instance-id for the httpd server
# each stack gets attached to a single tg
resource "aws_lb_target_group_attachment" "stack_lb_tga" {
  target_group_arn = data.aws_lb_target_group.staging.arn
  target_id        = aws_instance.httpd-ec2.id
  port             = 443
  availability_zone = "all"
}

# used to promote the tga to the live target group.
# by default deployment should be always deploying to the staging environment.
# using this 
variable "is_promote_lb_tg" {
  type	=	bool
  default = false
}

local {
  lb_target_stack = is_promote_lb_tg ? var.env_live_subdomain : var.env_staging_subdomain
}