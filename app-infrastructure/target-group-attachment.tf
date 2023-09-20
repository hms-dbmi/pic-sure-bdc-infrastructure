# Doing a lookup for the staging environments target group and attach the http instance that is being deployed
# Use tags for Project and Stack to find correct target group to update
data "aws_lb_target_group" "staging" {
  filter = {
    name = "tag:Project"
    values = [ local.project ]
  }
  filter = {
    name = "tag:Stack"
    values = [ var.env_staging_subdomain ]
  }
  # change this to find the target group dynamically
}

# use the arn from data resource staging.
# use the instance-id for the httpd server
resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_instance.staging.arn
  target_id        = aws_instance.httpd-ec2.id
  port             = 443
  availability_zone = "all"
}

variable "lb_tg_arn" {
  type    = string
}

variable "lb_tg_name" {
  type    = string
}

variable "target_id" {
  type    = string
}