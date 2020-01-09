
data "template_file" "httpd-user_data" {
  template = file("scripts/httpd-user_data.sh")
  vars = {
    stack_githash   = var.stack_githash_long
    fence_client_id = var.fence_client_id
    stack_s3_bucket = var.stack_s3_bucket
  }
}

data "template_cloudinit_config" "httpd-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.httpd-user_data.rendered
  }

}

resource "aws_instance" "httpd-ec2" {
  depends_on = [
    aws_key_pair.generated_key,
    aws_iam_instance_profile.httpd-deployment-s3-profile
  ]

  ami           = var.ami-id
  instance_type = "m5.large"

  associate_public_ip_address = true

  subnet_id = var.edge-subnet-us-east-1a-id

  iam_instance_profile = aws_iam_instance_profile.httpd-deployment-s3-profile.name

  key_name  = aws_key_pair.generated_key.key_name
  user_data = data.template_cloudinit_config.httpd-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.inbound-from-public-internet.id,
    aws_security_group.outbound-to-app.id
  ]
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 50
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - Apache HTTPD"
  }

}

resource "aws_route53_record" "httpd" {
  zone_id = var.internal-dns-zone-id
  name    = "httpd"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.httpd-ec2.private_ip]
}


data "template_file" "httpd-vhosts-conf" {
  template = file("configs/httpd-vhosts.conf")
  vars = {
    wildfly-base-url = var.wildfly-base-url
  }
}

resource "aws_s3_bucket_object" "httpd-vhosts-in-s3" {
  bucket                 = var.stack_s3_bucket
  key                    = "/configs/jenkins_pipeline_build_${var.stack_githash_long}/httpd-vhosts.conf"
  content                = data.template_file.httpd-vhosts-conf.rendered
  server_side_encryption = "aws:kms"
  kms_key_id             = var.kms_key_id
  acl = "private"
}

data "template_file" "picsureui_settings" {
  template = file("configs/picsureui_settings.json")
  vars = {
  }
}

resource "aws_s3_bucket_object" "picsureui_settings-in-s3" {
  bucket                 = var.stack_s3_bucket
  key                    = "/configs/jenkins_pipeline_build_${var.stack_githash_long}/picsureui_settings.json"
  content                = data.template_file.picsureui_settings.rendered
  server_side_encryption = "aws:kms"
  kms_key_id             = var.kms_key_id
  acl = "private"
}

data "template_file" "psamaui_settings" {
  template = file("configs/picsureui_settings.json")
  vars = {
    fence_client_id = var.fence_client_id
  }
}

resource "aws_s3_bucket_object" "psamaui_settings-in-s3" {
  bucket                 = var.stack_s3_bucket
  key                    = "/configs/jenkins_pipeline_build_${var.stack_githash_long}/psamaui_settings.json"
  content                = data.template_file.psamaui_settings.rendered
  server_side_encryption = "aws:kms"
  kms_key_id             = var.kms_key_id
  acl = "private"
}


