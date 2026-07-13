variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Назва VPC"
  type        = string
}

variable "public_subnets" {
  description = "Список CIDR блоків для публічних підмереж"
  type        = list(string)
}

variable "private_subnets" {
  description = "Список CIDR блоків для приватних підмереж"
  type        = list(string)
}

variable "availability_zones" {
  description = "Список зон доступності для підмереж"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Чи створювати NAT Gateway для приватних підмереж"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Чи увімкнути DNS hostnames у VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Чи увімкнути DNS підтримку у VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Теги для ресурсів"
  type        = map(string)
  default     = {}
}
