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

variable "django_db_password" {
  description = "Database password for django-app"
  type        = string
  sensitive   = true
}

variable "django_secret_key" {
  description = "Django SECRET_KEY for django-app"
  type        = string
  sensitive   = true
}
