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

variable "common_tags" {
  description = "Загальні теги для backend-ресурсів"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}
