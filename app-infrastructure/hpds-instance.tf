
data "template_file" "hpds-user_data" {
  template = file("scripts/hpds-user_data.sh")
  vars = {
    stack_githash = var.stack_githash_long
    dataset_s3_object_key = var.dataset_s3_object_key
    stack_s3_bucket = var.stack_s3_bucket
  }
}

data "template_cloudinit_config" "hpds-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.hpds-user_data.rendered
  }

}

resource "aws_instance" "hpds-ec2" {
  depends_on = [
    aws_key_pair.generated_key,
    local_file.wildfly-standalone-xml-file
  ]

  ami = var.ami-id
  instance_type = "m5.xlarge"

  associate_public_ip_address = true

  subnet_id = var.db-subnet-us-east-1a-id

  iam_instance_profile = "hpds-deployment-s3-profile-${var.stack_githash}"

  key_name = aws_key_pair.generated_key.key_name
  user_data = data.template_cloudinit_config.hpds-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.inbound-hpds-from-app.id,
    aws_security_group.outbound-to-trend-micro.id,
    aws_security_group.inbound-app-from-lma-for-dev-only.id
  ]
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 50
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - HPDS"
  }

}

resource "aws_route53_record" "hpds" {
  zone_id = var.internal-dns-zone-id
  name    = "hpds.${target-stack}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.hpds-ec2.private_ip]
}
