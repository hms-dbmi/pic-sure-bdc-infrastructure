resource "aws_db_instance" "pic-sure-mysql" {
  allocated_storage      = 50
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.small"
  name                   = "picsure"
  username               = "root"
  password               = random_password.picsure-db-password.result
  parameter_group_name   = "default.mysql5.7"
  storage_encrypted      = true
  db_subnet_group_name   = local.db_subnet_group_name
  copy_tags_to_snapshot  = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.inbound-mysql-from-wildfly.id]

  snapshot_identifier    = var.picsure_rds_snapshot_id

  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Stack       = var.target_stack
    Project     = var.env_project
    Name        = "PIC-SURE DB Instance - ${var.target_stack} - ${local.uniq_name}"
  }
}

resource "random_password" "picsure-db-password" {
  length  = 16
  special = false
}

data "template_file" "pic-sure-schema-sql" {
  template = file("configs/pic-sure-schema.sql")
  vars = {
    picsure_token_introspection_token = var.picsure_token_introspection_token
    target_stack                      = var.target_stack
    env_private_dns_name              = var.env_private_dns_name
    include_auth_hpds                 = var.include_auth_hpds
    include_open_hpds                 = var.include_open_hpds
  }
}

resource "local_file" "pic-sure-schema-sql-file" {
  content  = data.template_file.pic-sure-schema-sql.rendered
  filename = "pic-sure-schema.sql"
}

# Need to handle if the a stack is using a the hardcoded urls for resources in the db.
# Upserts on deployments will at least ensure a newly deployed stack is using the correct urls for resources
# This will not be a good methodology for standalone as each stack cannot use the same UUID. 
# Need a more dynamic and abstract method to find resources instead of hardcoding them into config files.
# Another table with simple uniq names that app can configure to lookup the UUIDs.
# 
data "template_file" "resources-registration" {
  template = file("configs/resources-registration.sql")
  vars = {
    picsure_token_introspection_token = var.picsure_token_introspection_token
    target_stack                      = var.target_stack
    env_private_dns_name              = var.env_private_dns_name
    include_auth_hpds                 = var.include_auth_hpds
    include_open_hpds                 = var.include_open_hpds
  }
}

resource "local_file" "resources-registration-file" {
  content  = data.template_file.pic-sure-schema-sql.rendered
  filename = "resources-registration.sql"
}