
data "template_file" "hpds-user_data" {
  template = file("scripts/hpds-user_data.sh")
  vars = {
    stack_githash = var.stack_githash_long
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

resource "aws_instance" "httpd-ec2" {
  depends_on = [
    aws_key_pair.generated_key,
    aws_iam_instance_profile.httpd-deployment-s3-profile
  ]

  ami = "ami-08b6e848c06d13bb3"
  instance_type = "m5.large"

  associate_public_ip_address = true

  subnet_id = var.edge-subnet-us-east-1a-id

  iam_instance_profile = aws_iam_instance_profile.httpd-deployment-s3-profile.name

  key_name = aws_key_pair.generated_key.key_name
  user_data = data.template_cloudinit_config.httpd-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.inbound-from-public-internet.id,
    aws_security_group.outbound-to-app.id
  ]
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 50
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - Apache HTTPD"
  }

}

