
resource "aws_security_group" "inbound-from-trend-micro" {
  name = "inbound-from-trend-micro"
  description = "Allow inbound traffic from TrendMicro DSA"
  vpc_id = aws_vpc.datastage-vpc.id

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
    Name        = "FISMA Terraform Playground - inbound-from-trend-micro Security Group"
  }
}

resource "aws_security_group" "outbound-to-trend-micro" {
  name = "outbound-to-trend-micro"
  description = "Allow outbound traffic from TrendMicro DSA"
  vpc_id = aws_vpc.datastage-vpc.id

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
    Name        = "FISMA Terraform Playground - outbound-to-trend-micro Security Group"
  }
}