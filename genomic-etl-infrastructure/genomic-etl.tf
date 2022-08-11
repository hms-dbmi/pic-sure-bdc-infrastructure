
data "template_file" "genomic-user_data" {
  template = file("scripts/genomic-etl.sh")
  vars = {
    stack_githash   = var.stack_githash_long
    stack_s3_bucket = var.stack_s3_bucket
    target-stack    = var.target-stack
  }
}

data "template_cloudinit_config" "genomic-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.genomic-user_data.rendered
  }

}

resource "aws_instance" "genomic-etl-ec2" {
  ami           = var.ami-id
  instance_type = "m5.large"

  associate_public_ip_address = true

  subnet_id = var.edge-subnet-us-east-1a-id

  iam_instance_profile = "genomic-etl-deployment-s3-profile-${var.target-stack}-${var.stack_githash}"

  user_data = data.template_cloudinit_config.genomic-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.inbound-from-public-internet.id,
    aws_security_group.outbound-to-app.id,
    aws_security_group.inbound-app-from-lma-for-dev-only.id
  ]
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 50
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - Genomic ETL - ${var.target-stack}"
    automaticPatches = "1"
  }

}



