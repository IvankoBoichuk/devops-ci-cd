variable "project_name" {
  description = "Назва проєкту"
  type        = string
  default     = "devops-ci-cd"
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

variable "common_tags" {
  description = "Загальні теги для всіх ресурсів"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

variable "rds_use_aurora" {
  description = "Якщо true, створюється Aurora Cluster; якщо false, створюється звичайний RDS instance"
  type        = bool
  default     = true
}

variable "rds_engine" {
  description = "Тип двигуна БД: postgres, mysql, aurora-postgresql або aurora-mysql"
  type        = string
  default     = "aurora-postgresql"
}

variable "rds_engine_version" {
  description = "Версія двигуна БД"
  type        = string
  default     = "16.4"
}

variable "rds_instance_class" {
  description = "Клас інстансу для RDS або Aurora writer/reader"
  type        = string
  default     = "db.t4g.medium"
}

variable "rds_multi_az" {
  description = "Вмикає Multi-AZ для звичайного RDS instance"
  type        = bool
  default     = false
}

variable "rds_db_name" {
  description = "Назва бази даних"
  type        = string
  default     = "appdb"
}

variable "rds_username" {
  description = "Master username"
  type        = string
  default     = "appuser"
}

variable "rds_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "rds_allocated_storage" {
  description = "Початковий розмір сховища в GB для звичайного RDS"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Максимальний autoscaling storage в GB для звичайного RDS"
  type        = number
  default     = 100
}

variable "rds_aurora_instance_count" {
  description = "Кількість інстансів Aurora в кластері; перший інстанс буде writer"
  type        = number
  default     = 1
}
