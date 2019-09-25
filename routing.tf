
resource "aws_route_table" "edge-route-table" {
  vpc_id = aws_vpc.edge-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.edge-gw.id
  }
  route {
    cidr_block = aws_subnet.app-private-subnet-us-east-1a.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.edge-app.id
  }
  route {
    cidr_block = aws_subnet.app-private-subnet-us-east-1b.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.edge-app.id
  }
  route {
    cidr_block = aws_subnet.app-private-subnet-us-east-1c.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.edge-app.id
  }
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Edge VPC Route Table"
  }
}

resource "aws_route_table_association" "edge-route-table-us-east-1a-association" {
  subnet_id = aws_subnet.edge-public-subnet-us-east-1a.id
  route_table_id = aws_route_table.edge-route-table.id
}
resource "aws_route_table_association" "edge-route-table-us-east-1b-association" {
  subnet_id = aws_subnet.edge-public-subnet-us-east-1b.id
  route_table_id = aws_route_table.edge-route-table.id
}
resource "aws_route_table_association" "edge-route-table-us-east-1c-association" {
  subnet_id = aws_subnet.edge-public-subnet-us-east-1c.id
  route_table_id = aws_route_table.edge-route-table.id
}

resource "aws_route_table" "app-route-table" {
  vpc_id = aws_vpc.app-vpc.id
  route {
    cidr_block    = aws_subnet.data-hpds-subnet-us-east-1a.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.app-data.id
  }
  route {
    cidr_block    = aws_subnet.data-hpds-subnet-us-east-1b.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.app-data.id
  }
  route {
    cidr_block    = aws_subnet.data-hpds-subnet-us-east-1c.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.app-data.id
  }
  route {
    cidr_block    = aws_subnet.data-db-subnet-us-east-1a.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.app-data.id
  }
  route {
    cidr_block    = aws_subnet.data-db-subnet-us-east-1b.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.app-data.id
  }
  route {
    cidr_block    = aws_subnet.data-db-subnet-us-east-1c.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.app-data.id
  }
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Edge VPC Route Table"
  }
}

resource "aws_route_table_association" "app-route-table-us-east-1a-association" {
  subnet_id = aws_subnet.app-private-subnet-us-east-1a.id
  route_table_id = aws_route_table.app-route-table.id
}
resource "aws_route_table_association" "app-route-table-us-east-1b-association" {
  subnet_id = aws_subnet.app-private-subnet-us-east-1b.id
  route_table_id = aws_route_table.app-route-table.id
}
resource "aws_route_table_association" "app-route-table-us-east-1c-association" {
  subnet_id = aws_subnet.app-private-subnet-us-east-1c.id
  route_table_id = aws_route_table.app-route-table.id
}
