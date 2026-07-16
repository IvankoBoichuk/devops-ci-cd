locals {
  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )

  bucket_name    = "${var.project_name}-terraform-state-${data.aws_caller_identity.current.account_id}"
  dynamodb_table = "${var.project_name}-terraform-locks"
}

data "aws_caller_identity" "current" {}

module "s3_backend" {
  source              = "../modules/s3-backend"
  bucket_name         = local.bucket_name
  dynamodb_table_name = local.dynamodb_table
  tags                = local.common_tags
}
