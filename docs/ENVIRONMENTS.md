# Приклади конфігурацій для різних оточень

## Development Environment

```hcl
# terraform.tfvars для development

# S3 Backend
bucket_name         = "mycompany-terraform-state-dev"
dynamodb_table_name = "terraform-locks-dev"

# VPC
vpc_cidr_block     = "10.0.0.0/16"
vpc_name           = "dev-vpc"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.4.0/24", "10.0.5.0/24"]
availability_zones = ["us-west-2a", "us-west-2b"]
enable_nat_gateway = true  # Можна вимкнути для економії

# ECR
ecr_name              = "dev-app-repo"
scan_on_push          = true
image_tag_mutability  = "MUTABLE"

# Tags
tags = {
  Environment = "development"
  Project     = "myapp"
  ManagedBy   = "terraform"
  CostCenter  = "engineering"
}
```

## Staging Environment

```hcl
# terraform.tfvars для staging

# S3 Backend
bucket_name         = "mycompany-terraform-state-staging"
dynamodb_table_name = "terraform-locks-staging"

# VPC
vpc_cidr_block     = "10.1.0.0/16"
vpc_name           = "staging-vpc"
public_subnets     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnets    = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
enable_nat_gateway = true

# ECR
ecr_name              = "staging-app-repo"
scan_on_push          = true
image_tag_mutability  = "MUTABLE"

# Tags
tags = {
  Environment = "staging"
  Project     = "myapp"
  ManagedBy   = "terraform"
  CostCenter  = "engineering"
}
```

## Production Environment

```hcl
# terraform.tfvars для production

# S3 Backend
bucket_name         = "mycompany-terraform-state-prod"
dynamodb_table_name = "terraform-locks-prod"

# VPC
vpc_cidr_block     = "10.2.0.0/16"
vpc_name           = "prod-vpc"
public_subnets     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
private_subnets    = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
enable_nat_gateway = true

# ECR
ecr_name              = "prod-app-repo"
scan_on_push          = true
image_tag_mutability  = "IMMUTABLE"  # Незмінні теги для production!

# Додаткові AWS accounts з доступом (наприклад, CI/CD account)
allowed_account_ids = ["123456789012"]

# Tags
tags = {
  Environment = "production"
  Project     = "myapp"
  ManagedBy   = "terraform"
  CostCenter  = "engineering"
  Compliance  = "required"
}
```

## Multi-Region Setup (Production DR)

```hcl
# terraform.tfvars для production в другому регіоні (disaster recovery)

# S3 Backend
bucket_name         = "mycompany-terraform-state-prod-eu"
dynamodb_table_name = "terraform-locks-prod-eu"

# VPC
vpc_cidr_block     = "10.3.0.0/16"
vpc_name           = "prod-eu-vpc"
public_subnets     = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
private_subnets    = ["10.3.4.0/24", "10.3.5.0/24", "10.3.6.0/24"]
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
enable_nat_gateway = true

# ECR
ecr_name              = "prod-eu-app-repo"
scan_on_push          = true
image_tag_mutability  = "IMMUTABLE"

# Tags
tags = {
  Environment = "production"
  Region      = "eu-west-1"
  Project     = "myapp"
  ManagedBy   = "terraform"
  CostCenter  = "engineering"
  DR          = "enabled"
}
```

## Використання різних оточень

### Варіант 1: Окремі директорії

```
.
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       ├── backend.tf
│       └── terraform.tfvars
└── modules/
    ├── s3-backend/
    ├── vpc/
    └── ecr/
```

### Варіант 2: Terraform Workspaces

```bash
# Створення workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Перемикання між оточеннями
terraform workspace select dev
terraform apply -var-file="dev.tfvars"

terraform workspace select prod
terraform apply -var-file="prod.tfvars"

# Список workspaces
terraform workspace list
```

### Варіант 3: Terragrunt (рекомендовано для великих проектів)

```hcl
# terragrunt.hcl
terraform {
  source = "../../modules/"
}

inputs = {
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
  # ...
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "mycompany-terraform-state-${local.environment}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks-${local.environment}"
  }
}
```

## Best Practices для різних оточень

### Development
- ✅ Використовуйте меншу кількість зон доступності (2 замість 3)
- ✅ Можна вимкнути NAT Gateway коли не використовується
- ✅ MUTABLE image tags для швидкої ітерації
- ✅ Менші instance types
- ⚠️ Автоматичне видалення ресурсів після робочого дня (cost saving)

### Staging
- ✅ Максимально близько до production
- ✅ Повний набір зон доступності
- ✅ Однакова мережева архітектура з production
- ✅ MUTABLE tags (але обережно)
- ⚠️ Менші розміри instances/RDS/ElastiCache

### Production
- ✅ 3+ зони доступності для high availability
- ✅ IMMUTABLE image tags (обов'язково!)
- ✅ Увімкнено всі security features
- ✅ Моніторинг та алертинг
- ✅ Automated backups
- ✅ Multi-region для DR (якщо потрібно)
- ⚠️ Змінні тільки через protected variables в CI/CD
- ⚠️ Manual approval для terraform apply

## Приклад CI/CD для різних оточень

```yaml
# .github/workflows/terraform.yml

name: Terraform Deploy

on:
  push:
    branches:
      - main          # Production
      - staging       # Staging
      - develop       # Development

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      
      - name: Determine environment
        id: env
        run: |
          if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "environment=prod" >> $GITHUB_OUTPUT
          elif [[ "${{ github.ref }}" == "refs/heads/staging" ]]; then
            echo "environment=staging" >> $GITHUB_OUTPUT
          else
            echo "environment=dev" >> $GITHUB_OUTPUT
          fi
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Plan
        run: terraform plan -var-file="${{ steps.env.outputs.environment }}.tfvars"
      
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve -var-file="prod.tfvars"
```

## Моніторинг витрат по оточенням

```bash
# AWS Cost Explorer CLI приклад
aws ce get-cost-and-usage \
  --time-period Start=2026-07-01,End=2026-07-31 \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --group-by Type=TAG,Key=Environment

# Результат покаже витрати по кожному оточенню
```

## Додаткові рекомендації

1. **Використовуйте різні AWS accounts** для dev/staging/prod (AWS Organizations)
2. **Автоматизуйте все** через CI/CD
3. **Тестуйте в dev**, валідуйте в staging, деплойте в prod
4. **Використовуйте git tags** для версіонування інфраструктури
5. **Документуйте зміни** в CHANGELOG.md
6. **Регулярні бекапи** state файлів
7. **Моніторинг витрат** та встановлення billing alarms
