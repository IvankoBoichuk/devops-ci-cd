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

output "rds_endpoint" {
  description = "RDS endpoint for django-app"
  value       = module.rds.db_endpoint
}

output "rds_port" {
  description = "RDS port for django-app"
  value       = module.rds.db_port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.db_name
}

output "rds_username" {
  description = "RDS master username"
  value       = module.rds.db_username
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

output "argo_cd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = module.argo_cd.argo_cd_namespace
}

output "argo_cd_url" {
  description = "URL for accessing Argo CD"
  value       = module.argo_cd.argo_cd_url
}

output "argo_cd_admin_password" {
  description = "Initial Argo CD admin password"
  value       = module.argo_cd.argo_cd_admin_password
  sensitive   = true
}

output "monitoring_namespace" {
  description = "Namespace where Prometheus and Grafana are installed"
  value       = module.monitoring.namespace
}

output "grafana_service_name" {
  description = "Grafana service name"
  value       = module.monitoring.grafana_service_name
}

output "grafana_admin_username" {
  description = "Grafana admin username"
  value       = module.monitoring.grafana_admin_username
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = module.monitoring.grafana_admin_password
  sensitive   = true
}

output "prometheus_service_name" {
  description = "Prometheus service name"
  value       = module.monitoring.prometheus_service_name
}
