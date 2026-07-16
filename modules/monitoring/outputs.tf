output "namespace" {
  description = "Namespace where monitoring stack is installed"
  value       = var.namespace
}

output "release_name" {
  description = "Monitoring Helm release name"
  value       = helm_release.monitoring.name
}

output "grafana_service_name" {
  description = "Grafana service name"
  value       = data.kubernetes_service_v1.grafana.metadata[0].name
}

output "grafana_admin_username" {
  description = "Grafana admin username"
  value       = "admin"
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = var.grafana_admin_password
  sensitive   = true
}

output "prometheus_service_name" {
  description = "Prometheus service name"
  value       = data.kubernetes_service_v1.prometheus.metadata[0].name
}
