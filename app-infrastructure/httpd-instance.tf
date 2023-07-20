
data "template_file" "httpd-user_data" {
  template = file("scripts/httpd-user_data.sh")
  vars = {
    stack_githash   = var.stack_githash_long
    fence_client_id = var.fence_client_id
    stack_s3_bucket = var.stack_s3_bucket
    dataset_s3_object_key = var.dataset_s3_object_key
    target_stack    = var.target_stack
    dsm_url = var.dsm_url
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
  ami           = var.ami-id
  instance_type = "m5.large"

  key_name = "biodata_nessus"

  associate_public_ip_address = false

  subnet_id = var.edge-subnet-us-east-1a-id

  iam_instance_profile = "httpd-deployment-s3-profile-${var.target_stack}-${var.stack_githash}"

  user_data = data.template_cloudinit_config.httpd-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.outbound-to-internet.id,
    aws_security_group.inbound-from-public-internet.id,
    aws_security_group.outbound-to-app.id,
    aws_security_group.inbound-edge-ssh-from-nessus.id
  ]
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 50
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - Apache HTTPD - ${var.target_stack}"
  }
  
  metadata_options {
  	http_endpoint = "enabled"
  	http_tokens = "required"
	  instance_metadata_tags = "enabled"  
  }

}

data "template_file" "httpd-vhosts-conf" {
  template = file("configs/httpd-vhosts.conf")
  vars = {
    allowed_hosts = var.allowed_hosts
    wildfly-base-url = "http://${aws_instance.wildfly-ec2.private_ip}:8080"
    target_stack = var.target_stack
    release-id = var.stack_githash_long
    env_private_dns_name = var.env_private_dns_name
    env_public_dns_name = var.env_public_dns_name
  }
}

resource "local_file" "httpd-vhosts-conf-file" {
    content     = data.template_file.httpd-vhosts-conf.rendered
    filename = "httpd-vhosts.conf"
}


data "template_file" "picsureui_settings" {
  template = file("configs/picsureui_settings.json")
  vars = {
    fence_client_id = var.fence_client_id
  }
}

resource "local_file" "picsureui-settings-json" {
    content     = data.template_file.picsureui_settings.rendered
    filename = "picsureui-settings.json"
}

