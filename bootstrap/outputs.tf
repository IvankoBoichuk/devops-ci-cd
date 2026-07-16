output "s3_bucket_name" {
  description = "Назва S3 бакета для Terraform state"
  value       = module.s3_backend.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN S3 бакета"
  value       = module.s3_backend.s3_bucket_arn
}

output "s3_bucket_region" {
  description = "Регіон S3 бакета"
  value       = module.s3_backend.s3_bucket_region
}

output "dynamodb_table_name" {
  description = "Назва DynamoDB таблиці для блокування"
  value       = module.s3_backend.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN DynamoDB таблиці"
  value       = module.s3_backend.dynamodb_table_arn
}
