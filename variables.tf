# Загальні змінні проекту

variable "project_name" {
  description = "Назва проекту"
  type        = string
  default     = "lesson-5"
}

variable "environment" {
  description = "Оточення (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS регіон"
  type        = string
  default     = "us-east-1"
}

# Змінні для VPC
variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Список зон доступності"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Змінні для EKS (якщо буде використовуватись)
variable "eks_cluster_name" {
  description = "Назва EKS кластера"
  type        = string
  default     = ""
}

# Загальні теги
variable "common_tags" {
  description = "Загальні теги для всіх ресурсів"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

# Змінні для Jenkins
variable "git_token" {
  description = "GitHub token for Jenkins JCasC"
  type        = string
  sensitive   = true
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "django_secret_key" {
  description = "Django SECRET_KEY for django-app"
  type        = string
  sensitive   = true
}

variable "rds_db_name" {
  description = "RDS database name for django-app"
  type        = string
  default     = "djangodb"
}

variable "rds_db_username" {
  description = "RDS database username for django-app"
  type        = string
  default     = "djangouser"
}

variable "rds_db_password" {
  description = "RDS database password for django-app"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[\\x21\\x23-\\x2E\\x30-\\x3F\\x41-\\x5B\\x5D-\\x7E]{8,128}$", var.rds_db_password))
    error_message = "rds_db_password must be 8-128 printable ASCII characters and must not contain space, double quote, slash, or @."
  }
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS in GiB"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum autoscaled storage for RDS in GiB"
  type        = number
  default     = 100
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot when destroying RDS"
  type        = bool
  default     = true
}

variable "rds_backup_retention_period" {
  description = "Backup retention period for RDS in days"
  type        = number
  default     = 7
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}
