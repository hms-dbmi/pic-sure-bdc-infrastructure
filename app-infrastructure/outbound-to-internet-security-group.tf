
resource "aws_security_group" "outbound-to-internet" {
  name = "allow_outbound_to_public_internet_${var.stack_githash}"
  description = "Allow outbound traffic to public internet"
  vpc_id = var.target-vpc
  
  egress {
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - outbound-to-internet Security Group - ${var.target-stack}"
  }
}
