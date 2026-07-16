output "db_instance_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.identifier
}

output "db_endpoint" {
  description = "RDS endpoint without port"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Database username"
  value       = aws_db_instance.this.username
}

output "security_group_id" {
  description = "Security group ID attached to the database"
  value       = aws_security_group.this.id
}
