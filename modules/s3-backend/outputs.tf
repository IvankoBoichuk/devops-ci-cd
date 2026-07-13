output "s3_bucket_name" {
  description = "Назва S3 бакета"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN S3 бакета"
  value       = aws_s3_bucket.terraform_state.arn
}

output "s3_bucket_region" {
  description = "Регіон S3 бакета"
  value       = aws_s3_bucket.terraform_state.region
}

output "dynamodb_table_name" {
  description = "Назва DynamoDB таблиці"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "dynamodb_table_arn" {
  description = "ARN DynamoDB таблиці"
  value       = aws_dynamodb_table.terraform_state_lock.arn
}
