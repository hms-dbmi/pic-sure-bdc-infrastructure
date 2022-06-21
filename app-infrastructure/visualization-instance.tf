
data "template_file" "visualization-user_data" {
  template = file("scripts/visualization-user_data.sh")
  vars = {
    stack_githash = var.stack_githash_long
    stack_s3_bucket = var.stack_s3_bucket
    target-stack = var.target-stack
  }
}


data "template_cloudinit_config" "visualization-user-data" {
  gzip          = true
  base64_encode = true

  # user_data
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.visualization-user_data.rendered
  }

}

resource "aws_instance" "visualization-ec2" {

  ami = var.ami-id
  //TODO double check this value at runtime to check that performance not impacted
  instance_type = "m5.large"

  key_name = "biodata_nessus"
  
  associate_public_ip_address = false

  subnet_id = var.app-subnet-us-east-1a-id

  iam_instance_profile = "visualization-deployment-s3-role-${var.target-stack}-${var.stack_githash}"

  user_data = data.template_cloudinit_config.visualization-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.outbound-to-internet.id,
    aws_security_group.inbound-hpds-from-app.id,
    aws_security_group.outbound-to-trend-micro.id,
    aws_security_group.inbound-data-ssh-from-nessus.id
  ]
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = 50
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - Visualization - ${var.target-stack}"
  }

}
