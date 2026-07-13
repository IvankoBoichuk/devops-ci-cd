output "vpc_id" {
  description = "ID VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR блок VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN VPC"
  value       = aws_vpc.main.arn
}

output "public_subnet_ids" {
  description = "Список ID публічних підмереж"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Список ID приватних підмереж"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "Список CIDR блоків публічних підмереж"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "Список CIDR блоків приватних підмереж"
  value       = aws_subnet.private[*].cidr_block
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "ID NAT Gateway"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : null
}

output "nat_gateway_public_ip" {
  description = "Публічний IP адрес NAT Gateway"
  value       = var.enable_nat_gateway ? aws_eip.nat[0].public_ip : null
}

output "public_route_table_id" {
  description = "ID публічної Route Table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID приватної Route Table"
  value       = aws_route_table.private.id
}
