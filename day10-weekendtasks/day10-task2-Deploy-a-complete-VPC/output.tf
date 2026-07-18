# outputs.tf

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc_name.id
}

output "subnet1_id" {
  description = "The ID of Subnet 1 (Public)"
  value       = aws_subnet.subnet1.id
}

output "subnet2_id" {
  description = "The ID of Subnet 2"
  value       = aws_subnet.subnet2.id
}

output "subnet3_id" {
  description = "The ID of Subnet 3"
  value       = aws_subnet.subnet3.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.ig.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.rt1.id
}

output "nat_gateway_eip" {
  description = "The Elastic IP address associated with the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private_route_table.id
}