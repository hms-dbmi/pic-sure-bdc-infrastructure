resource "aws_db_instance" "pic-sure-mysql" {
  allocated_storage = 50
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t3.small"
  name = "picsure"
  username = "root"
  password = "password"
  parameter_group_name = "default.mysql5.7"
  storage_encrypted = true
  db_subnet_group_name = "main-b"
  copy_tags_to_snapshot = true
  skip_final_snapshot = true
  snapshot_identifier = "arn:aws:rds:us-east-1:281165049757:snapshot:pic-sure-baseline"
  vpc_security_group_ids = [aws_security_group.inbound-mysql-from-app.id]
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - PIC-SURE DB Instance"
  }
}

resource "aws_route53_record" "picsure-db" {
  zone_id = var.internal-dns-zone-id
  name    = "picsure-db"
  type    = "A"
  ttl     = "300"
  records = [aws_db_instance.pic-sure-mysql.address]
}