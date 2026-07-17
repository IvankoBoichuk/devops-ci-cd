resource "helm_release" "monitoring" {
  name             = var.release_name
  namespace        = var.namespace
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.chart_version
  create_namespace = true

  atomic          = true
  cleanup_on_fail = true
  timeout         = 1800
  wait            = true

  values = [
    templatefile("${path.module}/values.yaml", {
      grafana_admin_password  = var.grafana_admin_password
      grafana_service_type    = var.grafana_service_type
      prometheus_service_type = var.prometheus_service_type
      storage_class           = var.storage_class
      grafana_storage_size    = var.grafana_storage_size
      prometheus_storage_size = var.prometheus_storage_size
    })
  ]
}

data "kubernetes_service_v1" "grafana" {
  metadata {
    name      = "${var.release_name}-grafana"
    namespace = var.namespace
  }

  depends_on = [helm_release.monitoring]
}

data "kubernetes_service_v1" "prometheus" {
  metadata {
    name      = "${var.release_name}-kube-prometheus-prometheus"
    namespace = var.namespace
  }

  depends_on = [helm_release.monitoring]
}
