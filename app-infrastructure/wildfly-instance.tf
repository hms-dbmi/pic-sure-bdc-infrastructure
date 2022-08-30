
data "template_file" "wildfly-user_data" {
  template = file("scripts/wildfly-user_data.sh")
  vars = {
    stack_githash   = var.stack_githash_long
    stack_s3_bucket = var.stack_s3_bucket
    dataset_s3_object_key = var.dataset-s3-object-key
    mysql-instance-address = aws_db_instance.pic-sure-mysql.address
    mysql-instance-password = random_password.picsure-db-password.result
    target-stack = var.target-stack
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
  ami           = var.ami-id
  instance_type = "m5.2xlarge"

  key_name = "biodata_nessus"

  associate_public_ip_address = false

  subnet_id = var.app-subnet-us-east-1a-id

  iam_instance_profile = "wildfly-deployment-s3-profile-${var.target-stack}-${var.stack_githash}"

  user_data = data.template_cloudinit_config.wildfly-user-data.rendered

  vpc_security_group_ids = [
    aws_security_group.outbound-to-internet.id,
    aws_security_group.inbound-from-edge.id,
    aws_security_group.outbound-to-hpds.id,
    aws_security_group.outbound-to-aurora.id,
    aws_security_group.outbound-to-trend-micro.id,
    aws_security_group.inbound-app-ssh-from-nessus.id
    aws_security_group.inbound-hpds-from-app.id,
  ]
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 150
  }

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - Wildfly - ${var.target-stack}"
  }

}

data "template_file" "wildfly-standalone-xml" {
  template = file("configs/standalone.xml")
  vars = {
    picsure-db-password               = random_password.picsure-db-password.result
    picsure_client_secret             = var.picsure_client_secret
    fence_client_secret               = var.fence_client_secret
    fence_client_id                   = var.fence_client_id
    target-stack                      = var.target-stack
    picsure_token_introspection_token = var.picsure_token_introspection_token
    mysql-instance-address            = aws_db_instance.pic-sure-mysql.address
  }
}

resource "local_file" "wildfly-standalone-xml-file" {
    content     = data.template_file.wildfly-standalone-xml.rendered
    filename = "standalone.xml"
}

data "template_file" "pic-sure-schema-sql" {
  template = file("configs/pic-sure-schema.sql")
  vars = {
    picsure_token_introspection_token = var.picsure_token_introspection_token
    target-stack                      = var.target-stack
  }
}

resource "local_file" "pic-sure-schema-sql-file" {
    content     = data.template_file.pic-sure-schema-sql.rendered
    filename = "pic-sure-schema.sql"
}


data "template_file" "aggregate-resource-properties" {
  template = file("configs/aggregate-resource.properties")
  vars = {
    target-stack                      = var.target-stack
  }
}

resource "local_file" "aggregate-resource-properties-file" {
    content     = data.template_file.aggregate-resource-properties.rendered
    filename = "aggregate-resource.properties"
}

