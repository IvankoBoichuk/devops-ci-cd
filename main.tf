# Локальні змінні для DRY принципу
locals {
  project_name = var.project_name
  environment  = var.environment

  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )

  # Генерація унікальних назв
  bucket_name      = "${var.project_name}-terraform-state-${data.aws_caller_identity.current.account_id}"
  dynamodb_table   = "${var.project_name}-terraform-locks"
  vpc_name         = "${var.project_name}-${var.environment}-vpc"
  ecr_name         = "${var.project_name}-${var.environment}-ecr"
  eks_cluster_name = var.eks_cluster_name != "" ? var.eks_cluster_name : "${var.project_name}-${var.environment}-eks"
}

# Отримання поточного AWS Account ID
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks" {
  name = local.eks_cluster_name
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name]
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name]
  }
}

# Підключаємо модуль S3 та DynamoDB
module "s3_backend" {
  source              = "./modules/s3-backend"
  bucket_name         = local.bucket_name
  dynamodb_table_name = local.dynamodb_table
  tags                = local.common_tags
}

# Підключаємо модуль VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = var.availability_zones
  vpc_name           = local.vpc_name
  tags               = local.common_tags
}

# Підключаємо модуль ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = local.ecr_name
  scan_on_push = true
  tags         = local.common_tags
}

# Підключаємо модуль EKS
module "eks" {
  source                  = "./modules/eks"
  cluster_name            = local.eks_cluster_name
  subnet_ids              = module.vpc.private_subnet_ids
  endpoint_private_access = true
  endpoint_public_access  = true

  # Налаштування worker nodes для application workloads та Jenkins
  instance_type = "t3.medium"
  desired_size  = 2
  max_size      = 2
  min_size      = 2

  tags = local.common_tags
}

module "jenkins" {
  source            = "./modules/jenkins"
  cluster_name      = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  bootstrap_pipeline_enabled = true

  pipeline_job_name    = "django-kaniko-pipeline"
  pipeline_repo_url    = "https://github.com/IvankoBoichuk/devops-ci-cd.git"
  pipeline_repo_branch = "lesson-8-9"
  pipeline_script_path = "Jenkinsfile"
  pipeline_ecr_repository  = module.ecr.repository_url
  pipeline_deploy_repo_url = "https://github.com/IvankoBoichuk/devops-ci-cd.git"
  pipeline_deploy_values_file = "charts/django-app/values.yaml"
  pipeline_deploy_branch = "lesson-8-9"

  admin_password = var.jenkins_admin_password
  git_username = "IvankoBoichuk"
  git_token    = var.git_token

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "argo_cd" {
  source   = "./modules/argo_cd"
  repo_url = "https://github.com/IvankoBoichuk/devops-ci-cd.git"
  django_db_password = var.django_db_password
  django_secret_key  = var.django_secret_key
  applications = [
    {
      name            = "django-app"
      namespace       = "argocd"
      target_revision = "lesson-8-9"
      path            = "charts/django-app"
      destination_ns  = "default"
      helm_parameters = [
        {
          name  = "service.type"
          value = "LoadBalancer"
        },
        {
          name  = "postgresql.storageClass"
          value = "gp2"
        },
        {
          name  = "replicaCount"
          value = "1"
        },
        {
          name  = "autoscaling.minReplicas"
          value = "1"
        },
        {
          name  = "secret.create"
          value = "false"
        },
        {
          name  = "secret.existingSecret"
          value = "django-app-app"
        }
      ]
    }
  ]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}
