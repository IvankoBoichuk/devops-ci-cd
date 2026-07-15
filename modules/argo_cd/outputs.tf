locals {
  argo_cd_lb_hostname = try(data.kubernetes_service_v1.argo_cd_server.status[0].load_balancer[0].ingress[0].hostname, null)
  argo_cd_lb_ip       = try(data.kubernetes_service_v1.argo_cd_server.status[0].load_balancer[0].ingress[0].ip, null)
}

output "argo_cd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = var.namespace
}

output "argo_cd_url" {
  description = "URL for accessing Argo CD"
  value = local.argo_cd_lb_hostname != null ? "http://${local.argo_cd_lb_hostname}" : (
    local.argo_cd_lb_ip != null ? "http://${local.argo_cd_lb_ip}" : "http://${var.release_name}-server.${var.namespace}.svc.cluster.local"
  )
}

output "argo_cd_admin_password" {
  description = "Initial Argo CD admin password"
  value       = nonsensitive(data.kubernetes_secret_v1.initial_admin_password.data.password)
  sensitive   = true
}
