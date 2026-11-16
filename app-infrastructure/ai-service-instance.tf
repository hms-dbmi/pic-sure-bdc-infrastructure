# pic-sure-ai-service runs on its own host so it gets its own instance profile (Bedrock) and
# IMDS hop limit, and so a model-side problem cannot take the PIC-SURE wildfly host down.
# The gateway reaches it at ai-service.<stack>.<env_private_dns_name>:8080; it calls back to the
# gateway published on wildfly.<stack>.<env_private_dns_name>:8080.

resource "aws_security_group" "inbound-ai-service-from-wildfly" {
  count       = var.include_ai_service ? 1 : 0
  name        = "allow_inbound_from_wildfly_to_ai_service_${local.uniq_name}"
  description = "Allow inbound traffic from wildfly on port 8080 for pic-sure-ai-service"
  vpc_id      = local.target_vpc

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.inbound-wildfly-from-httpd.id]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Name        = "inbound-ai-service Security Group - ${var.target_stack} - ${local.uniq_name}"
  }
}

resource "aws_security_group" "inbound-wildfly-from-ai-service" {
  count       = var.include_ai_service ? 1 : 0
  name        = "allow_inbound_from_ai_service_to_wildfly_${local.uniq_name}"
  description = "Allow inbound traffic from pic-sure-ai-service on port 8080 for the gateway"
  vpc_id      = local.target_vpc

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.inbound-ai-service-from-wildfly[0].id]
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Name        = "inbound-wildfly-from-ai-service Security Group - ${var.target_stack} - ${local.uniq_name}"
  }
}

data "template_file" "ai_service-user_data" {
  template = file("scripts/ai_service-user_data.sh")
  vars = {
    stack_s3_bucket      = var.stack_s3_bucket
    target_stack         = var.target_stack
    gss_prefix           = "${var.environment_prefix}_${var.env_is_open_access ? "open" : "auth"}_${var.environment_name}"
    environment_name     = var.environment_name
    env_private_dns_name = var.env_private_dns_name
  }
}

data "template_cloudinit_config" "ai_service-user-data" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.ai_service-user_data.rendered
  }
}

resource "aws_instance" "ai-service-ec2" {
  count = var.include_ai_service ? 1 : 0

  ami           = local.ami_id
  instance_type = "m7a.large"

  subnet_id = local.private2_subnet_ids[0]

  iam_instance_profile = aws_iam_instance_profile.ai-service-deployment-profile.name

  user_data = data.template_cloudinit_config.ai_service-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.outbound-to-internet.id,
    aws_security_group.inbound-ai-service-from-wildfly[0].id
  ]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 50
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Stack       = var.target_stack
    Project     = local.project
    Name        = "AI Service - ${var.target_stack} - ${local.uniq_name}"
  }

  # The container reaches the instance role through IMDS, which is one network hop further than the
  # host; the default hop limit of 1 would hide the credentials from it.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }
}

resource "aws_route53_record" "ai-service-addr-record" {
  count   = var.include_ai_service ? 1 : 0
  zone_id = var.env_hosted_zone_id
  name    = "ai-service.${var.target_stack}.${var.env_private_dns_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.ai-service-ec2[0].private_ip]
}
