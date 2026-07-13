# ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = var.ecr_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(
    var.tags,
    {
      Name = var.ecr_name
    }
  )
}

# Lifecycle policy для автоматичного видалення старих образів
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Зберігати тільки останні 10 образів"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Отримання поточного AWS Account ID
data "aws_caller_identity" "current" {}

# Політика доступу для ECR репозиторію
resource "aws_ecr_repository_policy" "main" {
  count      = var.enable_repository_policy ? 1 : 0
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = concat(
            ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"],
            [for account_id in var.allowed_account_ids : "arn:aws:iam::${account_id}:root"]
          )
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      },
      {
        Sid    = "AllowECSPull"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      },
      {
        Sid    = "AllowLambdaPull"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Condition = {
          StringLike = {
            "aws:sourceArn" = "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:*"
          }
        }
      }
    ]
  })
}
