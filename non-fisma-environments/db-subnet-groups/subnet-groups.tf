
resource "aws_db_subnet_group" "data-subnet-group-a" {
  name       = "main-a"
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
resource "aws_db_subnet_group" "data-subnet-group-b" {
  name       = "main-b"
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