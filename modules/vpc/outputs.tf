output "vpc_id" {
  description = "ID VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR блок VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Список ID публічних підмереж"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Список ID приватних підмереж"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_public_ip" {
  description = "Публічний IP адрес NAT Gateway"
  value       = var.enable_nat_gateway ? aws_eip.nat[0].public_ip : null
}
