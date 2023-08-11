data "template_file" "wildfly-user_data" {
  template = file("scripts/wildfly-user_data.sh")
  vars = {
    stack_githash           = var.stack_githash_long
    stack_s3_bucket         = var.stack_s3_bucket
    dataset_s3_object_key   = var.dataset_s3_object_key
    mysql-instance-address  = aws_db_instance.pic-sure-mysql.address
    mysql-instance-password = random_password.picsure-db-password.result
    target_stack            = var.target_stack
    env_private_dns_name    = var.env_private_dns_name
    env_public_dns_name     = var.env_public_dns_name
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
  ami           = local.ami_id
  instance_type = "m5.2xlarge"

  subnet_id = local.private2_subnet_ids[0]

  iam_instance_profile = "wildfly-deployment-s3-profile-${var.target_stack}-${var.stack_githash}"

  user_data = data.template_cloudinit_config.wildfly-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.outbound-to-internet.id,
    aws_security_group.inbound-wildfly-from-httpd.id
  ]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 150
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Stack       = var.env_staging_subdomain
    Name        = "{var.stack_githash} - Wildfly - ${var.target_stack}"
  }

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

}

data "template_file" "wildfly-standalone-xml" {
  template = file("configs/standalone.xml")
  vars = {
    picsure-db-password               = random_password.picsure-db-password.result
    picsure_client_secret             = var.picsure_client_secret
    fence_client_secret               = var.fence_client_secret
    fence_client_id                   = var.fence_client_id
    target_stack                      = var.target_stack
    picsure_token_introspection_token = var.picsure_token_introspection_token
    mysql-instance-address            = aws_db_instance.pic-sure-mysql.address
    env_private_dns_name              = var.env_private_dns_name
    env_public_dns_name               = var.env_public_dns_name
  }
}

resource "local_file" "wildfly-standalone-xml-file" {
  content  = data.template_file.wildfly-standalone-xml.rendered
  filename = "standalone.xml"
}

data "template_file" "pic-sure-schema-sql" {
  template = file("configs/pic-sure-schema.sql")
  vars = {
    picsure_token_introspection_token = var.picsure_token_introspection_token
    target_stack                      = var.target_stack
    env_private_dns_name              = var.env_private_dns_name
  }
}

resource "local_file" "pic-sure-schema-sql-file" {
  content  = data.template_file.pic-sure-schema-sql.rendered
  filename = "pic-sure-schema.sql"
}


data "template_file" "aggregate-resource-properties" {
  template = file("configs/aggregate-resource.properties")
  vars = {
    target_stack         = var.target_stack
    env_private_dns_name = var.env_private_dns_name
  }
}

resource "local_file" "aggregate-resource-properties-file" {
  content  = data.template_file.aggregate-resource-properties.rendered
  filename = "aggregate-resource.properties"
}

data "template_file" "visualization-resource-properties" {
  template = file("configs/visualization-resource.properties")
  vars = {
    target_stack = var.target_stack
  }
}

resource "local_file" "visualization-resource-properties-file" {
  content  = data.template_file.visualization-resource-properties.rendered
  filename = "visualization-resource.properties"
}
