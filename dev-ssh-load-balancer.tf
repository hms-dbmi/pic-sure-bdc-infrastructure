resource "aws_lb" "dev-ssh-lb" {
  name               = "dev-ssh-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.app-private-subnet-us-east-1a.id]

  tags = {
    Environment = "development"    
    Owner       = "Avillach_Lab"
    Name        = "FISMA Terraform Playground - dev-ssh-lb"
  }
}


resource "aws_lb_listener" "ssh-listener" {
  load_balancer_arn = aws_lb.dev-ssh-lb.arn
  port              = "22"
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ssh-target-group.arn
  }
}

resource "aws_lb_target_group" "ssh-target-group" {
  name     = "ssh-target-group"
  port     = 22
  protocol = "TCP"
  vpc_id   = aws_vpc.app-vpc.id
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.wildfly-autoscaling-group.id
  elb                    = aws_lb.dev-ssh-lb.id
}