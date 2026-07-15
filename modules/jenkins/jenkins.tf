resource "helm_release" "jenkins" {
  name             = var.release_name
  namespace        = var.namespace
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = var.chart_version
  create_namespace = true

  atomic          = true
  cleanup_on_fail = true
  timeout         = 1800
  wait            = true

  values = [
    templatefile("${path.module}/values.yaml", {
      release_name              = var.release_name
      admin_username            = var.admin_username
      admin_password            = var.admin_password
      service_type              = var.service_type
      service_port              = var.service_port
      storage_class             = var.storage_class
      storage_size              = var.storage_size
      controller_cpu_request    = var.controller_cpu_request
      controller_memory_request = var.controller_memory_request
      controller_cpu_limit      = var.controller_cpu_limit
      controller_memory_limit   = var.controller_memory_limit
      install_plugins           = var.install_plugins
      ingress_enabled           = var.ingress_enabled
      ingress_class_name        = var.ingress_class_name
      ingress_host              = var.ingress_host
      ingress_tls_secret_name   = var.ingress_tls_secret_name
    })
  ]
}
