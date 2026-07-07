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

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Name        = "monitoring Security Group - ${local.uniq_name}"
  }
}
