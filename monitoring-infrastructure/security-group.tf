resource "aws_security_group" "monitoring" {
  name        = "monitoring_${local.uniq_name}"
  description = "PIC-SURE monitoring instance (Prometheus/Grafana); source SG for metrics scraping"
  vpc_id      = local.target_vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    self        = true
    description = "self-scrape of monitoring host exporters"
  }

  ingress {
    from_port   = 9882
    to_port     = 9882
    protocol    = "tcp"
    self        = true
    description = "self-scrape of monitoring host exporters"
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Name        = "monitoring Security Group - ${local.uniq_name}"
  }
}
