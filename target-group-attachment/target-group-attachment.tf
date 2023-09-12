provider "aws" {
  region  = "us-east-1"
  profile = "avillachlab-secure-infrastructure"
  version = "3.74"

}

data "aws_lb_target_group" "test" {
  arn  = var.lb_tg_arn
  name = var.lb_tg_name
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = data.aws_lb_target_group.test.arn
  target_id        = var.target_id
  port             = 443
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