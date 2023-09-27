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
  tags = {
    Owner       = "Avillach_Lab"
    Environment = var.environment_name
    Stack       = var.target_stack
    Project     = var.env_project
    Name        = "PIC-SURE DB Instance - ${var.target_stack} - ${var.stack_githash}"
  }
}

resource "random_password" "picsure-db-password" {
  length  = 16
  special = false
}
