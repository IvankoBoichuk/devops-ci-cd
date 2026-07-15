# Outputs для S3 Backend
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

# Outputs для VPC
output "vpc_id" {
  description = "ID VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR блок VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Список ID публічних підмереж"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Список ID приватних підмереж"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_public_ip" {
  description = "Публічний IP адрес NAT Gateway"
  value       = module.vpc.nat_gateway_public_ip
}

# Outputs для ECR
output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Назва ECR репозиторію"
  value       = module.ecr.repository_name
}

# Outputs для EKS
output "eks_cluster_endpoint" {
  description = "Endpoint EKS кластера для підключення"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Назва EKS кластера"
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "ARN IAM ролі для EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}

output "jenkins_release" {
  description = "Jenkins Helm release name"
  value       = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  description = "Namespace where Jenkins is installed"
  value       = module.jenkins.jenkins_namespace
}

output "jenkins_url" {
  description = "URL for accessing Jenkins"
  value       = module.jenkins.jenkins_url
}

output "jenkins_admin_password" {
  description = "Jenkins admin password"
  value       = module.jenkins.jenkins_admin_password
  sensitive   = true
}
