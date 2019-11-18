
resource "aws_default_route_table" "datastage-route-table" {
  default_route_table_id = aws_vpc.datastage-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inet-gw.id
  }
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - ${var.stack_githash} - DataSTAGE VPC Route Table"
  }
}

resource "aws_route_table_association" "edge-route-table-us-east-1a-association" {
  subnet_id = aws_subnet.edge-subnet-us-east-1a.id
  route_table_id = aws_vpc.datastage-vpc.default_route_table_id
}
resource "aws_route_table_association" "edge-route-table-us-east-1b-association" {
  subnet_id = aws_subnet.edge-subnet-us-east-1b.id
  route_table_id = aws_vpc.datastage-vpc.default_route_table_id
}

resource "aws_route_table_association" "app-route-table-us-east-1a-association" {
  subnet_id = aws_subnet.app-subnet-us-east-1a.id
  route_table_id = aws_vpc.datastage-vpc.default_route_table_id
}
resource "aws_route_table_association" "app-route-table-us-east-1b-association" {
  subnet_id = aws_subnet.app-subnet-us-east-1b.id
  route_table_id = aws_vpc.datastage-vpc.default_route_table_id
}

resource "aws_route_table_association" "data-db-route-table-us-east-1a-association" {
  subnet_id = aws_subnet.db-subnet-us-east-1a.id
  route_table_id = aws_vpc.datastage-vpc.default_route_table_id
}
resource "aws_route_table_association" "data-db-route-table-us-east-1b-association" {
  subnet_id = aws_subnet.db-subnet-us-east-1b.id
  route_table_id = aws_vpc.datastage-vpc.default_route_table_id
}

resource "aws_route_table_association" "data-hpds-route-table-us-east-1a-association" {
  subnet_id = aws_subnet.hpds-subnet-us-east-1a.id
  route_table_id = aws_vpc.datastage-vpc.default_route_table_id
}
resource "aws_route_table_association" "data-hpds-route-table-us-east-1b-association" {
  subnet_id = aws_subnet.hpds-subnet-us-east-1b.id
  route_table_id = aws_vpc.datastage-vpc.default_route_table_id
}