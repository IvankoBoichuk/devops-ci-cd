resource "aws_iam_role" "jenkins_kaniko_role" {
  name = "${var.cluster_name}-jenkins-kaniko-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:jenkins-sa"
            "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_ecr_policy" {
  name = "${var.cluster_name}-jenkins-kaniko-ecr-policy"
  role = aws_iam_role.jenkins_kaniko_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = "*"
      }
    ]
  })
}

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
      bootstrap_pipeline_enabled = var.bootstrap_pipeline_enabled
      pipeline_job_name          = var.pipeline_job_name
      pipeline_repo_url          = var.pipeline_repo_url
      pipeline_repo_branch       = var.pipeline_repo_branch
      pipeline_script_path       = var.pipeline_script_path
      pipeline_ecr_repository    = var.pipeline_ecr_repository
      pipeline_deploy_repo_url   = var.pipeline_deploy_repo_url
      pipeline_deploy_values_file = var.pipeline_deploy_values_file
      pipeline_deploy_branch     = var.pipeline_deploy_branch
      pipeline_repo_credentials_id = var.pipeline_repo_credentials_id
      gitops_credentials_id      = var.gitops_credentials_id
      git_username               = var.git_username
      git_token                  = var.git_token
      ingress_enabled           = var.ingress_enabled
      ingress_class_name        = var.ingress_class_name
      ingress_host              = var.ingress_host
      ingress_tls_secret_name   = var.ingress_tls_secret_name
    })
  ]
}

resource "kubernetes_service_account_v1" "jenkins_sa" {
  metadata {
    name      = "jenkins-sa"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.jenkins_kaniko_role.arn
    }
  }

  depends_on = [helm_release.jenkins]
}

resource "kubernetes_role_v1" "deploy_manager" {
  metadata {
    name      = "jenkins-deploy-manager"
    namespace = var.deploy_namespace
  }

  rule {
    api_groups = [""]
    resources = [
      "configmaps",
      "endpoints",
      "persistentvolumeclaims",
      "pods",
      "secrets",
      "serviceaccounts",
      "services",
    ]
    verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources = [
      "deployments",
      "replicasets",
      "statefulsets",
    ]
    verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources = ["horizontalpodautoscalers"]
    verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources = ["ingresses"]
    verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding_v1" "deploy_manager" {
  metadata {
    name      = "jenkins-deploy-manager"
    namespace = var.deploy_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.deploy_manager.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.jenkins_sa.metadata[0].name
    namespace = var.namespace
  }
}
