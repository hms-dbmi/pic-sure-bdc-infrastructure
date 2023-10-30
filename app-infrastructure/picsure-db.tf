# Take snaphot of current live RDS and propagate 
data "aws_db_snapshot" "snapshot" {
  most_recent = true

  filter {
    name   = "tag:Project"
    values = [ var.env_project ]
  }

  filter {
    name   = "tag:Stack"
    values = [ var.live_stack ]
  }
}

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

  # If a snapshot is not found in the ata.aws_db_snapshot.snapshot.id it will just create a new rds without using it
  # gracefully according to tf
  snapshot_identifier    = data.aws_db_snapshot.snapshot.id

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
