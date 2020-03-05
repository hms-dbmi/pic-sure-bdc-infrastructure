resource "aws_route53_zone" "internal_dns" {
  name = "local"

  vpc {
    vpc_id = aws_vpc.datastage-vpc.id
  }
}