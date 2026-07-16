output "endpoint" {
  description = "Writer endpoint бази даних"
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
}

output "reader_endpoint" {
  description = "Reader endpoint Aurora або endpoint звичайного RDS instance"
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : aws_db_instance.this[0].address
}

output "port" {
  description = "Порт БД"
  value       = local.port
}

output "security_group_id" {
  description = "ID security group для БД"
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "Назва DB subnet group"
  value       = aws_db_subnet_group.this.name
}

output "parameter_group_name" {
  description = "Назва DB parameter group"
  value       = aws_db_parameter_group.this.name
}

output "cluster_parameter_group_name" {
  description = "Назва cluster parameter group для Aurora"
  value       = var.use_aurora ? aws_rds_cluster_parameter_group.this[0].name : null
}

output "instance_id" {
  description = "ID звичайного RDS instance"
  value       = var.use_aurora ? null : aws_db_instance.this[0].id
}

output "cluster_id" {
  description = "ID Aurora cluster"
  value       = var.use_aurora ? aws_rds_cluster.this[0].id : null
}

output "aurora_instance_ids" {
  description = "Список ID Aurora instances"
  value       = var.use_aurora ? aws_rds_cluster_instance.this[*].id : []
}
