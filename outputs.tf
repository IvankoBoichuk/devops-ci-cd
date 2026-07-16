output "vpc_id" {
  description = "ID VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Список ID приватних підмереж"
  value       = module.vpc.private_subnet_ids
}

output "rds_endpoint" {
  description = "Writer endpoint бази даних"
  value       = module.rds.endpoint
}

output "rds_reader_endpoint" {
  description = "Reader endpoint для Aurora або endpoint інстансу для звичайного RDS"
  value       = module.rds.reader_endpoint
}

output "rds_security_group_id" {
  description = "ID security group для бази даних"
  value       = module.rds.security_group_id
}

output "rds_subnet_group_name" {
  description = "Назва DB subnet group"
  value       = module.rds.db_subnet_group_name
}
