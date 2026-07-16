variable "namespace" {
  description = "Namespace for Prometheus and Grafana"
  type        = string
  default     = "monitoring"
}

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "kube-prometheus-stack chart version"
  type        = string
  default     = "70.4.2"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_service_type" {
  description = "Service type for Grafana"
  type        = string
  default     = "ClusterIP"
}

variable "prometheus_service_type" {
  description = "Service type for Prometheus"
  type        = string
  default     = "ClusterIP"
}

variable "storage_class" {
  description = "Storage class for Prometheus and Grafana PVCs"
  type        = string
  default     = "gp2"
}

variable "grafana_storage_size" {
  description = "Grafana persistent volume size"
  type        = string
  default     = "10Gi"
}

variable "prometheus_storage_size" {
  description = "Prometheus persistent volume size"
  type        = string
  default     = "20Gi"
}
