
data "template_file" "hpds-user_data" {
  template = file("scripts/hpds-user_data.sh")
  vars = {
    stack_githash = var.stack_githash_long
    dataset_s3_object_key = var.dataset-s3-object-key
    genomic_dataset_s3_object_key = var.genomic-dataset-s3-object-key
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

  ami = var.ami-id
  instance_type = "m5.2xlarge"

  associate_public_ip_address = true

  subnet_id = var.db-subnet-us-east-1a-id

  iam_instance_profile = "hpds-deployment-s3-profile-${var.target-stack}-${var.stack_githash}"

  user_data = data.template_cloudinit_config.hpds-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.inbound-hpds-from-app.id,
    aws_security_group.outbound-to-trend-micro.id,
    aws_security_group.inbound-app-from-lma-for-dev-only.id
  ]
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 1000
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - HPDS - ${var.target-stack}"
  }

}
