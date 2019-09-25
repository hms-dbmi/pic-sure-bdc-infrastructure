resource "aws_vpc_peering_connection" "edge-app" {
  vpc_id	= aws_vpc.edge-vpc.id
  peer_vpc_id 	= aws_vpc.app-vpc.id
  auto_accept 	= true
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Edge to App VPC Peering Connection"
  }
}

resource "aws_vpc_peering_connection" "app-data" {
  vpc_id	= aws_vpc.app-vpc.id
  peer_vpc_id 	= aws_vpc.data-vpc.id
  auto_accept 	= true
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - App to Data VPC Peering Connection"
  }
}

resource "aws_route_table" "edge-app-route-table" {
  vpc_id	= aws_vpc.edge-vpc.id
  
  route {
    cidr_block 	= aws_vpc.app-vpc.cidr_block
    vpc_peering_connection_id	= aws_vpc_peering_connection.edge-app.id
  }
  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - Edge to App Route Table"
  }

}

resource "aws_route_table" "app-data-route-table" {
  vpc_id	= aws_vpc.app-vpc.id
  
  route {
    cidr_block 	= aws_vpc.data-vpc.cidr_block
    vpc_peering_connection_id	= aws_vpc_peering_connection.app-data.id
  }  

  tags = {
    Owner       = "Avillach_Lab"
    Environment = "development"
    Name        = "FISMA Terraform Playground - App to Data Route Table"
  }

}
