
resource "aws_db_subnet_group" "data-subnet-group" {
  name = "main"
  subnet_ids = [
    var.db-subnet-a-us-east-1a-id,
    var.db-subnet-a-us-east-1b-id
  ]
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - DB Subnet Group A"
  }
}
resource "aws_db_subnet_group" "data-subnet-group" {
  name = "main-b"
  subnet_ids = [
    var.db-subnet-b-us-east-1a-id,
    var.db-subnet-b-us-east-1b-id
  ]
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - DB Subnet Group B"
  }
}
