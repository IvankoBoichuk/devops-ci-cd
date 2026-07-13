# Підключаємо модуль S3 та DynamoDB
module "s3_backend" {
  source              = "./modules/s3-backend"
  bucket_name         = "goit-terraform-state-ivanb"  # ЗАМІНІТЬ на вашу унікальну назву
  dynamodb_table_name = "terraform-locks"

  tags = {
    Environment = "dev"
    Project     = "lesson-5"
  }
}

# Підключаємо модуль VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_name           = "lesson-5-vpc"

  tags = {
    Environment = "dev"
    Project     = "lesson-5"
  }
}

# Підключаємо модуль ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-5-ecr"
  scan_on_push = true

  tags = {
    Environment = "dev"
    Project     = "lesson-5"
  }
}
