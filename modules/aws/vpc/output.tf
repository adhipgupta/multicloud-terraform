
output "route_table_id" {
  value = aws_route_table.route_table.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}