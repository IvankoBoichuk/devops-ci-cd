output "repository_url" {
  description = "URL ECR репозиторію"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_arn" {
  description = "ARN ECR репозиторію"
  value       = aws_ecr_repository.main.arn
}

output "repository_name" {
  description = "Назва ECR репозиторію"
  value       = aws_ecr_repository.main.name
}

output "registry_id" {
  description = "Registry ID"
  value       = aws_ecr_repository.main.registry_id
}

output "repository_registry_id" {
  description = "ID реєстру репозиторію"
  value       = aws_ecr_repository.main.registry_id
}

output "repository_policy" {
  description = "JSON політики доступу до репозиторію"
  value       = var.enable_repository_policy ? aws_ecr_repository_policy.main[0].policy : null
}

output "scan_on_push_enabled" {
  description = "Чи увімкнене сканування при push"
  value       = aws_ecr_repository.main.image_scanning_configuration[0].scan_on_push
}
