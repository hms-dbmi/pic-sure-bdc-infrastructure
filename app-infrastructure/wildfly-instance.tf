resource "tls_private_key" "development-only-app-server-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
output "provisioning-private-key" {
  value = tls_private_key.development-only-app-server-key.private_key_pem
}
resource "aws_key_pair" "generated_key" {
  key_name   = "development-only-app-server-key"
  public_key = tls_private_key.development-only-app-server-key.public_key_openssh
}

data "template_file" "wildfly-user_data" {
  template = file("scripts/wildfly-user_data.sh")
  vars = {
    stack_githash = var.stack_githash_long
  }
}

data "template_cloudinit_config" "wildfly-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.wildfly-user_data.rendered
  }

}

resource "aws_instance" "wildfly-ec2" {
  depends_on = [
    aws_key_pair.generated_key,
    aws_iam_instance_profile.wildfly-deployment-s3-profile,
    data.template_file.wildfly-standalone-xml
  ]

  ami = "ami-08b6e848c06d13bb3"
  instance_type = "m5.large"

  associate_public_ip_address = true

  subnet_id = var.app-subnet-us-east-1a-id

  iam_instance_profile = aws_iam_instance_profile.wildfly-deployment-s3-profile.name

  key_name = aws_key_pair.generated_key.key_name
  user_data = data.template_cloudinit_config.wildfly-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.inbound-from-edge.id,
    aws_security_group.outbound-to-hpds.id,
    aws_security_group.outbound-to-aurora.id,
    aws_security_group.inbound-app-from-lma-for-dev-only.id,
    aws_security_group.outbound-to-trend-micro.id
  ]
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 50
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - Wildfly"
  }

}

resource "aws_route53_record" "wildfly" {
  zone_id = var.internal-dns-zone-id
  name    = "wildfly"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.wildfly-ec2.private_ip]
}

data "template_file" "wildfly-standalone-xml" {
  depends_on = [
    aws_route53_record.picsure-db
  ]
  template = file("configs/standalone.xml")
  vars = {
    picsure-db-password = random_password.picsure-db-password.result
    picsure_client_secret = var.picsure_client_secret
    fence_client_secret = var.fence_client_secret
    fence_client_id = var.fence_client_id
  }
}

resource "aws_s3_bucket_object" "standalone-xml-in-s3" {
  bucket = "avillach-datastage-pic-sure-jenkins-dev-builds-3"
  key    = "/configs/jenkins_pipeline_build_${var.stack_githash_long}/standalone.xml"
  content = template_file.wildfly-standalone-xml.rendered
}