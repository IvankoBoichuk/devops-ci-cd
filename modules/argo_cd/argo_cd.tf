resource "helm_release" "argo_cd" {
  name             = var.release_name
  namespace        = var.namespace
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  create_namespace = true

  atomic          = true
  cleanup_on_fail = true
  timeout         = 1800
  wait            = true

  values = [
    templatefile("${path.module}/values.yaml", {
      service_type = var.service_type
    })
  ]
}

resource "kubernetes_secret_v1" "django_app" {
  metadata {
    name      = var.django_secret_name
    namespace = "default"
  }

  type = "Opaque"

  data = {
    DB_USER     = var.django_db_user
    DB_PASSWORD = var.django_db_password
    SECRET_KEY  = var.django_secret_key
  }
}

resource "helm_release" "applications" {
  name      = "${var.release_name}-apps"
  namespace = var.namespace
  chart     = "${path.module}/charts"
  version   = var.applications_chart_version

  atomic          = true
  cleanup_on_fail = true
  timeout         = 600
  wait            = true

  values = [
    yamlencode({
      repositories = [
        {
          name     = "primary-repo"
          url      = var.repo_url
          username = var.repo_username
          password = var.repo_password
        }
      ]
      applications = [
        for app in var.applications : {
          name             = app.name
          namespace        = app.namespace
          project          = app.project
          repoUrl          = coalesce(try(app.repo_url, null), var.repo_url)
          targetRevision   = app.target_revision
          path             = app.path
          destinationName  = app.destination_name
          destinationNamespace = app.destination_ns
          helmParameters   = app.helm_parameters
          syncOptions      = app.sync_options
        }
      ]
    })
  ]

  depends_on = [
    helm_release.argo_cd,
    kubernetes_secret_v1.django_app,
  ]
}

data "kubernetes_service_v1" "argo_cd_server" {
  metadata {
    name      = "${var.release_name}-server"
    namespace = var.namespace
  }

  depends_on = [helm_release.argo_cd]
}

data "kubernetes_secret_v1" "initial_admin_password" {
  metadata {
    name      = "${var.release_name}-initial-admin-secret"
    namespace = var.namespace
  }

  depends_on = [helm_release.argo_cd]
}
