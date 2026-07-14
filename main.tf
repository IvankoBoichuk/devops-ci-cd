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

  # Налаштування worker nodes (Free Tier)
  instance_type = "t3.small"
  desired_size  = 1
  max_size      = 2
  min_size      = 1

  tags = local.common_tags
}
