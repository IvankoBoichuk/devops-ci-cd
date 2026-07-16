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

  vpc_name = "${var.project_name}-${var.environment}-vpc"
  rds_name = "${var.project_name}-${var.environment}-db"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = var.availability_zones
  vpc_name           = local.vpc_name
  tags               = local.common_tags
}

module "rds" {
  source = "./modules/rds"

  identifier     = local.rds_name
  use_aurora     = var.rds_use_aurora
  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class
  multi_az       = var.rds_multi_az

  db_name  = var.rds_db_name
  username = var.rds_username
  password = var.rds_password

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]

  aurora_instance_count = var.rds_aurora_instance_count
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage

  tags = local.common_tags
}
