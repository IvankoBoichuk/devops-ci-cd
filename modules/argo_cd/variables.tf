variable "namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "release_name" {
  description = "Helm release name for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD chart version"
  type        = string
  default     = "10.1.3"
}

variable "service_type" {
  description = "Service type for Argo CD server"
  type        = string
  default     = "LoadBalancer"
}

variable "applications_chart_version" {
  description = "Version of the local Argo CD applications chart"
  type        = string
  default     = "0.1.0"
}

variable "repo_url" {
  description = "Git repository URL watched by Argo CD"
  type        = string
}

variable "repo_username" {
  description = "Optional username for Argo CD repository access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "repo_password" {
  description = "Optional password/token for Argo CD repository access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "applications" {
  description = "List of Argo CD applications to create"
  type = list(object({
    name             = string
    namespace        = string
    project          = optional(string, "default")
    repo_url         = optional(string)
    target_revision  = string
    path             = string
    destination_name = optional(string, "in-cluster")
    destination_ns   = string
    helm_parameters = optional(list(object({
      name  = string
      value = string
    })), [])
    sync_options = optional(list(string), ["CreateNamespace=true"])
  }))
}

variable "django_secret_name" {
  description = "Existing secret name used by the django-app Helm chart"
  type        = string
  default     = "django-app-app"
}

variable "django_db_user" {
  description = "Database username for django-app secret"
  type        = string
  default     = "djangouser"
}

variable "django_db_password" {
  description = "Database password for django-app secret"
  type        = string
  sensitive   = true
}

variable "django_secret_key" {
  description = "Django SECRET_KEY for django-app secret"
  type        = string
  sensitive   = true
}
