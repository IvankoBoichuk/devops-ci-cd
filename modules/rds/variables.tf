variable "identifier" {
  description = "Базовий ідентифікатор для RDS instance або Aurora cluster"
  type        = string
}

variable "use_aurora" {
  description = "Якщо true, створюється Aurora Cluster; якщо false, створюється звичайний RDS instance"
  type        = bool
  default     = true
}

variable "engine" {
  description = "Тип двигуна БД: postgres, mysql, aurora-postgresql або aurora-mysql"
  type        = string

  validation {
    condition     = contains(["postgres", "mysql", "aurora-postgresql", "aurora-mysql"], var.engine)
    error_message = "engine must be one of: postgres, mysql, aurora-postgresql, aurora-mysql."
  }
}

variable "engine_version" {
  description = "Версія двигуна БД"
  type        = string
}

variable "instance_class" {
  description = "Клас інстансу БД"
  type        = string
}

variable "multi_az" {
  description = "Вмикає Multi-AZ для звичайного RDS instance"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Назва бази даних"
  type        = string
}

variable "username" {
  description = "Master username"
  type        = string
}

variable "password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "ID VPC, де буде створено security group"
  type        = string
}

variable "subnet_ids" {
  description = "Список приватних subnet IDs для DB subnet group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR блоки, яким дозволено доступ до БД"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security groups, яким дозволено доступ до БД"
  type        = list(string)
  default     = []
}

variable "parameter_group_family" {
  description = "Явне значення family для aws_db_parameter_group; якщо null, Terraform спробує вивести його з engine та engine_version"
  type        = string
  default     = null
}

variable "cluster_parameter_group_family" {
  description = "Явне значення family для aws_rds_cluster_parameter_group; використовується лише для Aurora"
  type        = string
  default     = null
}

variable "port" {
  description = "Порт БД; якщо null, буде обрано типовий для engine"
  type        = number
  default     = null
}

variable "allocated_storage" {
  description = "Початковий розмір сховища в GB для звичайного RDS"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Максимальний autoscaling storage в GB для звичайного RDS"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Тип сховища для звичайного RDS"
  type        = string
  default     = "gp3"
}

variable "aurora_instance_count" {
  description = "Кількість інстансів Aurora у кластері"
  type        = number
  default     = 1

  validation {
    condition     = var.aurora_instance_count >= 1
    error_message = "aurora_instance_count must be at least 1."
  }
}

variable "publicly_accessible" {
  description = "Чи буде БД доступною публічно"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Скільки днів зберігати backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Вікно для backup у форматі hh:mm-hh:mm"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Вікно для maintenance"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "apply_immediately" {
  description = "Застосовувати зміни відразу"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Захист від видалення"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Чи пропустити фінальний snapshot при видаленні"
  type        = bool
  default     = true
}

variable "max_connections" {
  description = "Значення max_connections у parameter group"
  type        = string
  default     = "200"
}

variable "log_statement" {
  description = "Значення log_statement у parameter group"
  type        = string
  default     = "ddl"
}

variable "work_mem" {
  description = "Значення work_mem у parameter group"
  type        = string
  default     = "4096"
}

variable "tags" {
  description = "Теги для ресурсів"
  type        = map(string)
  default     = {}
}
