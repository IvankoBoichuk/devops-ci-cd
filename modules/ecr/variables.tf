variable "ecr_name" {
  description = "Назва ECR репозиторію"
  type        = string
}

variable "scan_on_push" {
  description = "Чи сканувати образи на вразливості при завантаженні"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Чи можна перезаписувати теги образів"
  type        = string
  default     = "MUTABLE"
}

variable "tags" {
  description = "Теги для ресурсів"
  type        = map(string)
  default     = {}
}

variable "allowed_account_ids" {
  description = "Список AWS Account ID, які мають доступ до репозиторію"
  type        = list(string)
  default     = []
}

variable "enable_repository_policy" {
  description = "Чи створювати політику доступу для репозиторію"
  type        = bool
  default     = true
}
