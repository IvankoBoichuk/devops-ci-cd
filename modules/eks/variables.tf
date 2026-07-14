variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
}

variable "subnet_ids" {
  description = "Список ID підмереж для EKS кластера (зазвичай приватні)"
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Чи увімкнути приватний доступ до EKS API"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Чи увімкнути публічний доступ до EKS API"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Теги для EKS ресурсів"
  type        = map(string)
  default     = {}
}

variable "instance_type" {
  description = "Тип EC2 інстансів для worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Бажана кількість worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Максимальна кількість worker nodes"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Мінімальна кількість worker nodes"
  type        = number
  default     = 1
}
