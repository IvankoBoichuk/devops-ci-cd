variable "bucket_name" {
  description = "Назва S3 бакета для Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Назва DynamoDB таблиці для блокування state"
  type        = string
  default     = "terraform-state-lock"
}

variable "tags" {
  description = "Теги для ресурсів"
  type        = map(string)
  default     = {}
}
