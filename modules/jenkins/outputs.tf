output "jenkins_release_name" {
  description = "Jenkins Helm release name"
  value       = helm_release.jenkins.name
}

output "jenkins_namespace" {
  description = "Namespace where Jenkins is installed"
  value       = helm_release.jenkins.namespace
}

output "jenkins_url" {
  description = "URL for accessing Jenkins"
  value       = var.ingress_enabled && var.ingress_host != "" ? "https://${var.ingress_host}" : "http://${var.release_name}.${var.namespace}.svc.cluster.local:${var.service_port}"
}

output "jenkins_admin_password" {
  description = "Jenkins admin password"
  value       = var.admin_password
  sensitive   = true
}
