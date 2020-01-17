
resource "aws_security_group" "inbound-from-trend-micro" {
  name = "inbound-from-trend-micro_${var.stack_githash}"
  description = "Allow inbound traffic from TrendMicro DSA"
  vpc_id = var.target-vpc

  ingress {
    from_port = 4118
    to_port = 4118
    protocol = "tcp"
    cidr_blocks = [
      "172.25.255.78/32"
    ]
  }
  
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - inbound-from-trend-micro Security Group - ${var.target-stack}"
  }
}

resource "aws_security_group" "outbound-to-trend-micro" {
  name = "outbound-to-trend-micro_${var.stack_githash}"
  description = "Allow outbound traffic from TrendMicro DSA"
  vpc_id = var.target-vpc

  egress {
    from_port = 4120
    to_port = 4120
    protocol = "tcp"
    cidr_blocks = [
      "172.25.255.78/32"
    ]
  }
  
  egress {
    from_port = 5274
    to_port = 5274
    protocol = "tcp"
    cidr_blocks = [
      "172.25.255.78/32"
    ]
  }
  
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - outbound-to-trend-micro Security Group - ${var.target-stack}"
  }
}