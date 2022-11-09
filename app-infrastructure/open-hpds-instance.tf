
data "template_file" "open_hpds-user_data" {
  template = file("scripts/open_hpds-user_data.sh")
  vars = {
    stack_githash = var.stack_githash_long
    destigmatized_dataset_s3_object_key = var.destigmatized-dataset-s3-object-key
    stack_s3_bucket = var.stack_s3_bucket
    target-stack    = var.target-stack
  }
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

  key_name = "biodata_nessus"

  associate_public_ip_address = false

  subnet_id = var.db-subnet-us-east-1a-id

  iam_instance_profile = "open-hpds-deployment-s3-profile-${var.target-stack}-${var.stack_githash}"

  user_data = data.template_cloudinit_config.open_hpds-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.outbound-to-internet.id,
    aws_security_group.inbound-hpds-from-app.id,
    aws_security_group.outbound-to-trend-micro.id,
    aws_security_group.inbound-data-ssh-from-nessus.id
  ]
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 1000
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - Open HPDS - ${var.target-stack}"
  }
  
  metadata_options {
  	http_endpoint = "enabled"
  	http_tokens = "required"
	  instance_metadata_tags = "enabled"  
  }

}

