
data "template_file" "open_hpds-user_data" {
  template = file("scripts/open_hpds-user_data.sh")
  vars = {
    stack_githash = var.stack_githash_long
    dataset_s3_object_key = var.dataset-s3-object-key
    stack_s3_bucket = var.stack_s3_bucket
  }
}

data "template_file" "aggregate-resource-properties" {
  template = file("scripts/aggregate-resource.properties")
  vars = {
    target-stack = var.target-stack
  }
}

resource "local_file" "aggregate-resource-properties-file" {
    content     = data.template_file.aggregate-resource-properties.rendered
    filename = "aggregate-resource.properties"
}

data "template_cloudinit_config" "open_hpds-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.open_hpds-user_data.rendered
  }

}

resource "aws_instance" "open-hpds-ec2" {

  ami = var.ami-id
  instance_type = "m5.2xlarge"

  associate_public_ip_address = true

  subnet_id = var.db-subnet-us-east-1a-id

  iam_instance_profile = "hpds-deployment-s3-profile-${var.target-stack}-${var.stack_githash}"

  user_data = data.template_cloudinit_config.open_hpds-user-data.rendered

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
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - OPEN HPDS - ${var.target-stack}"
  }

}
