# Terraform AWS Infrastructure

Цей проект налаштовує фінальну інфраструктуру AWS за допомогою Terraform, включаючи:
- S3 бакет для зберігання Terraform state файлів з версіюванням
- DynamoDB таблицю для блокування state файлів
- VPC з публічними та приватними підмережами (3-зональна архітектура)
- EKS кластер для Kubernetes workloads
- RDS PostgreSQL у приватних підмережах
- ECR репозиторій для Docker образів з автоматичним скануванням
- Jenkins для CI
- Argo CD для GitOps
- Prometheus і Grafana для моніторингу

## Загальна архітектура

```
┌─────────────────────────────────────────────────────────────────────┐
│                         AWS Infrastructure                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │               Terraform State Backend                       │  │
│  │  ┌────────────────────┐    ┌──────────────────────┐         │  │
│  │  │  S3 Bucket         │    │  DynamoDB Table      │         │  │
│  │  │  - State files     │◄───┤  - State locking    │         │  │
│  │  │  - Versioning ON   │    │  - PAY_PER_REQUEST   │         │  │
│  │  │  - Encryption      │    └──────────────────────┘         │  │
│  │  └────────────────────┘                                     │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    VPC Network (10.0.0.0/16)                │  │
│  │                                                              │  │
│  │  ┌──────────────────────────────────────────────┐           │  │
│  │  │         Internet Gateway                     │           │  │
│  │  └─────────────────┬────────────────────────────┘           │  │
│  │                    │                                         │  │
│  │  ┌─────────────────┴──────────────────────────────────────┐ │  │
│  │  │  Public Subnets (3 AZs)                                │ │  │
│  │  │  10.0.1.0/24 | 10.0.2.0/24 | 10.0.3.0/24               │ │  │
│  │  │  ┌────────────────┐                                    │ │  │
│  │  │  │  NAT Gateway   │                                    │ │  │
│  │  │  │  + Elastic IP  │                                    │ │  │
│  │  │  └────────┬───────┘                                    │ │  │
│  │  └───────────┼────────────────────────────────────────────┘ │  │
│  │              │                                               │  │
│  │  ┌───────────┴──────────────────────────────────────────┐   │  │
│  │  │  Private Subnets (3 AZs)                             │   │  │
│  │  │  10.0.4.0/24 | 10.0.5.0/24 | 10.0.6.0/24              │   │  │
│  │  │  [ECS Tasks, RDS, ElastiCache, etc.]                 │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │       EKS + CI/CD + Monitoring                             │  │
│  │  ECR + Jenkins + Argo CD + Prometheus + Grafana            │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## Структура проекту

```
.
├── main.tf              # Головний файл конфігурації
├── backend.tf           # Налаштування backend для Terraform state
├── outputs.tf           # Виведення значень
├── bootstrap/           # Окремий stack для S3 backend і lock table
├── modules/
│   ├── s3-backend/      # Модуль для S3 та DynamoDB
│   ├── vpc/             # Модуль для VPC
│   ├── ecr/             # Модуль для ECR
│   ├── eks/             # Модуль для EKS
│   ├── rds/             # Модуль для PostgreSQL в RDS
│   ├── jenkins/         # Модуль для Jenkins
│   ├── argo_cd/         # Модуль для Argo CD
│   └── monitoring/      # Prometheus + Grafana
```

## Jenkins + Argo CD Workflow

### Як застосувати Terraform

1. Створіть локальний файл змінних:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Заповніть у `terraform.tfvars` секретні значення:
- `jenkins_admin_password`
- `git_token`
- `rds_db_password`
- `django_secret_key`
- `grafana_admin_password`

3. Спочатку створіть backend через окремий bootstrap stack:

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
cd ..
```

4. Після цього ініціалізуйте основний stack на S3 backend:

```bash
terraform init -upgrade -reconfigure
```

5. Застосуйте інфраструктуру:

```bash
terraform apply
```

6. Корисні outputs після успішного `apply`:

```bash
terraform output jenkins_url
terraform output jenkins_admin_password
terraform output argo_cd_url
terraform output argo_cd_admin_password
terraform output ecr_repository_url
terraform output rds_endpoint
terraform output grafana_service_name
terraform output prometheus_service_name
```

7. Після застосування перевірте базовий стан кластера:

```bash
kubectl get nodes
kubectl get pods -n jenkins
kubectl get pods -n argocd
kubectl get pods -n monitoring
kubectl get applications -n argocd
```

9. Перевірка сервісів для фінального захисту:

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring

kubectl port-forward svc/jenkins 8080:8080 -n jenkins
kubectl port-forward svc/argocd-server 8081:443 -n argocd
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
```

8. Швидкий доступ до Jenkins, Argo CD і сайту:

```bash
# Argo CD URL
terraform output -raw argo_cd_url

# Argo CD admin password
terraform output -raw argo_cd_admin_password

# Jenkins services
kubectl get svc -n jenkins

# Якщо Jenkins має LoadBalancer, дивіться EXTERNAL-IP/hostname
kubectl get svc -n jenkins jenkins

# Jenkins admin password
terraform output -raw jenkins_admin_password

# Якщо Jenkins ще без зовнішнього LoadBalancer
kubectl port-forward -n jenkins svc/jenkins 8080:8080

# Django service / зовнішня адреса сайту
kubectl get svc django-app-django

# Повний список зовнішніх сервісів
kubectl get svc -A
```

### Як перевірити Jenkins job

1. Відкрийте Jenkins за адресою з:

```bash
terraform output jenkins_url
```

2. Зайдіть під:
- `admin`
- пароль з `terraform output jenkins_admin_password`

3. Знайдіть job:
- `django-kaniko-pipeline`

4. Запустіть `Build with Parameters` і перевірте, що параметри заповнені:
- `ECR_REPOSITORY`
- `DEPLOY_REPO_URL`
- `DEPLOY_VALUES_FILE`
- `DEPLOY_BRANCH`

5. Після успішного запуску перевірте:
- у log є push image в ECR
- у Git оновився `charts/django-app/values.yaml`

Швидка перевірка з терміналу:

```bash
git show lesson-8-9:charts/django-app/values.yaml | rg "tag:"
```

### Як побачити результат в Argo CD

1. Відкрийте Argo CD за адресою з:

```bash
terraform output argo_cd_url
```

2. Логін:
- username: `admin`
- пароль з:

```bash
terraform output argo_cd_admin_password
```

Або напряму:

```bash
terraform output -raw argo_cd_url
```

3. Перевірте, що застосунок `django-app` існує:

```bash
kubectl get applications -n argocd
```

4. Перевірте, що після push у Git Argo CD переходить:
- `OutOfSync`
- потім `Synced`

```bash
kubectl get applications -n argocd -w
```

5. Перевірте, який image реально задеплоєний у кластер:

```bash
kubectl get deployment django-app-django -o jsonpath='{.spec.template.spec.containers[0].image}'
echo
```

6. Перевірте результат на сервісі:

```bash
kubectl get svc django-app-django
curl http://<LOADBALANCER-HOSTNAME>/
```

Для Jenkins:

```bash
kubectl get svc -n jenkins
kubectl get svc -n jenkins jenkins
terraform output -raw jenkins_admin_password
```

Якщо Jenkins не має зовнішнього `LoadBalancer`, використайте:

```bash
kubectl port-forward -n jenkins svc/jenkins 8080:8080
```

і відкрийте `http://localhost:8080`.

### Загальна схема

1. Jenkins збирає Docker image.
2. Jenkins пушить image в ECR.
3. Jenkins оновлює `charts/django-app/values.yaml` у Git.
4. Argo CD бачить зміну в Git.
5. Argo CD автоматично синхронізує зміни в Kubernetes.

## Модуль S3 Backend

### Що налаштовано:

1. **S3 Бакет**:
   - Версіювання увімкнено для збереження історії змін state файлів
   - Server-side шифрування (AES256)
   - Блокування публічного доступу
   - Теги для організації ресурсів

2. **DynamoDB Таблиця**:
   - Налаштована для блокування state файлів
   - Режим оплати: PAY_PER_REQUEST (платите за запити)
   - Hash key: `LockID` (обов'язково для Terraform)

### Змінні модуля:

- `bucket_name` - назва S3 бакета (обов'язково)
- `dynamodb_table_name` - назва DynamoDB таблиці (за замовчуванням: "terraform-state-lock")
- `tags` - додаткові теги для ресурсів

### Виведення (outputs):

- `s3_bucket_name` - назва створеного S3 бакета
- `s3_bucket_arn` - ARN S3 бакета
- `s3_bucket_region` - регіон S3 бакета
- `dynamodb_table_name` - назва DynamoDB таблиці
- `dynamodb_table_arn` - ARN DynamoDB таблиці

## Модуль VPC

### Що налаштовано:

1. **VPC (Virtual Private Cloud)**:
   - Кастомний CIDR блок (за замовчуванням 10.0.0.0/16)
   - Увімкнений DNS hostname та DNS support
   - Ізольована мережева інфраструктура

2. **Публічні підмережі (3 шт)**:
   - Розподілені по різним зонам доступності
   - Автоматичне призначення публічних IP адрес
   - Доступ до інтернету через Internet Gateway

3. **Приватні підмережі (3 шт)**:
   - Розподілені по різним зонам доступності
   - Доступ до інтернету через NAT Gateway
   - Ізольовані від прямого доступу з інтернету

4. **Internet Gateway**:
   - Забезпечує доступ до інтернету для публічних підмереж
   - Двостороння комунікація з інтернетом

5. **NAT Gateway**:
   - Дозволяє приватним підмережам отримувати доступ до інтернету
   - Одностороння комунікація (вихідний трафік)
   - Розміщений в першій публічній підмережі
   - Elastic IP для статичної адреси

6. **Маршрутизація**:
   - Публічна Route Table → Internet Gateway для публічних підмереж
   - Приватна Route Table → NAT Gateway для приватних підмереж
   - Автоматичні асоціації підмереж з відповідними таблицями

### Змінні модуля:

- `vpc_cidr_block` - CIDR блок для VPC (за замовчуванням: "10.0.0.0/16")
- `vpc_name` - назва VPC (обов'язково)
- `public_subnets` - список CIDR блоків для публічних підмереж (обов'язково)
- `private_subnets` - список CIDR блоків для приватних підмереж (обов'язково)
- `availability_zones` - список зон доступності (обов'язково)
- `enable_nat_gateway` - створювати NAT Gateway (за замовчуванням: true)
- `enable_dns_hostnames` - увімкнути DNS hostnames (за замовчуванням: true)
- `enable_dns_support` - увімкнути DNS підтримку (за замовчуванням: true)
- `tags` - додаткові теги для ресурсів

### Виведення (outputs):

- `vpc_id` - ID створеного VPC
- `vpc_cidr_block` - CIDR блок VPC
- `vpc_arn` - ARN VPC
- `public_subnet_ids` - список ID публічних підмереж
- `private_subnet_ids` - список ID приватних підмереж
- `public_subnet_cidrs` - список CIDR блоків публічних підмереж
- `private_subnet_cidrs` - список CIDR блоків приватних підмереж
- `internet_gateway_id` - ID Internet Gateway
- `nat_gateway_id` - ID NAT Gateway
- `nat_gateway_public_ip` - публічний IP адрес NAT Gateway
- `public_route_table_id` - ID публічної route table
- `private_route_table_id` - ID приватної route table

### Архітектура мережі:

```
┌─────────────────────────────────────────────────────────────────────┐
│                              VPC (10.0.0.0/16)                      │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Internet Gateway                          │  │
│  └─────────────────────────┬────────────────────────────────────┘  │
│                            │                                        │
│  ┌─────────────────────────┴────────────────────────────────────┐  │
│  │              Public Route Table (0.0.0.0/0 → IGW)            │  │
│  └──┬───────────────────┬───────────────────┬───────────────────┘  │
│     │                   │                   │                       │
│  ┌──▼────────────────┐ ┌▼──────────────────┐ ┌▼──────────────────┐│
│  │Public Subnet      │ │Public Subnet      │ │Public Subnet      ││
│  │10.0.1.0/24        │ │10.0.2.0/24        │ │10.0.3.0/24        ││
│  │us-west-2a         │ │us-west-2b         │ │us-west-2c         ││
│  │ ┌──────────────┐  │ │                   │ │                   ││
│  │ │ NAT Gateway  │  │ │                   │ │                   ││
│  │ │ + Elastic IP │  │ │                   │ │                   ││
│  │ └──────┬───────┘  │ │                   │ │                   ││
│  └────────┼──────────┘ └───────────────────┘ └───────────────────┘│
│           │                                                         │
│  ┌────────┴──────────────────────────────────────────────────────┐ │
│  │         Private Route Table (0.0.0.0/0 → NAT Gateway)         │ │
│  └──┬───────────────────┬───────────────────┬───────────────────┘ │
│     │                   │                   │                      │
│  ┌──▼────────────────┐ ┌▼──────────────────┐ ┌▼──────────────────┐│
│  │Private Subnet     │ │Private Subnet     │ │Private Subnet     ││
│  │10.0.4.0/24        │ │10.0.5.0/24        │ │10.0.6.0/24        ││
│  │us-west-2a         │ │us-west-2b         │ │us-west-2c         ││
│  │                   │ │                   │ │                   ││
│  └───────────────────┘ └───────────────────┘ └───────────────────┘│
└─────────────────────────────────────────────────────────────────────┘
```

### Приклад використання:

```hcl
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  vpc_name           = "my-vpc"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

```

## Модуль ECR

### Що налаштовано:

1. **ECR Repository**:
   - Приватний Docker registry для зберігання контейнерних образів
   - **Автоматичне сканування на вразливості** при push образів (scan on push)
   - Налаштована мутабельність тегів (MUTABLE/IMMUTABLE)

2. **Lifecycle Policy**:
   - Автоматичне видалення старих образів
   - Збереження останніх 10 образів
   - Економія місця та витрат

3. **Repository Policy (Політика доступу)**:
   - Дозволяє поточному AWS account push та pull образи
   - Автоматичний доступ для ECS tasks (pull only)
   - Автоматичний доступ для Lambda функцій (pull only)
   - Можливість додати інші AWS accounts через змінну `allowed_account_ids`
   - Детальний контроль доступу через IAM permissions

### Змінні модуля:

- `ecr_name` - назва ECR репозиторію (обов'язково)
- `scan_on_push` - сканувати образи на вразливості при push (за замовчуванням: true)
- `image_tag_mutability` - чи можна перезаписувати теги (за замовчуванням: "MUTABLE")
- `enable_repository_policy` - створювати політику доступу (за замовчуванням: true)
- `allowed_account_ids` - список додаткових AWS Account ID з доступом (за замовчуванням: [])
- `tags` - додаткові теги для ресурсів

### Виведення (outputs):

- `repository_url` - URL репозиторію для push/pull образів
- `repository_arn` - ARN репозиторію
- `repository_name` - назва репозиторію
- `registry_id` - ID реєстру
- `repository_policy` - JSON політики доступу
- `scan_on_push_enabled` - статус сканування при push

### Приклад використання:

```hcl
module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = "my-app-repo"
  scan_on_push = true
  
  # Додати доступ для інших AWS accounts
  allowed_account_ids = [
    "123456789012",  # Dev account
    "987654321098"   # Prod account
  ]
  
  # Незмінні теги (рекомендовано для production)
  image_tag_mutability = "IMMUTABLE"
  
  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### Політика доступу

Модуль автоматично створює політику доступу, яка дозволяє:

1. **Поточний AWS Account** - повний доступ (push/pull)
2. **ECS Tasks** - тільки pull образів для запуску контейнерів
3. **Lambda Functions** - тільки pull образів для контейнерних Lambda
4. **Додаткові Accounts** - повний доступ через `allowed_account_ids`

Приклад згенерованої політики:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPushPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ]
    }
  ]
}
```

### Робота з ECR:

```bash
# Аутентифікація в ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url | cut -d/ -f1)

# Build Docker образу
docker build -t my-app:latest .

# Тегування для ECR
docker tag my-app:latest $(terraform output -raw ecr_repository_url):latest

# Push до ECR
docker push $(terraform output -raw ecr_repository_url):latest

# Pull з ECR
docker pull $(terraform output -raw ecr_repository_url):latest

# Перегляд результатів сканування
aws ecr describe-image-scan-findings \
  --repository-name $(terraform output -raw ecr_repository_name) \
  --image-id imageTag=latest

# Список образів в репозиторії
aws ecr describe-images \
  --repository-name $(terraform output -raw ecr_repository_name)

# Видалення образу
aws ecr batch-delete-image \
  --repository-name $(terraform output -raw ecr_repository_name) \
  --image-ids imageTag=old-tag
```

### Сканування на вразливості

При увімкненому `scan_on_push = true`:
- Кожен новий образ автоматично сканується після push
- Виявляються вразливості CVE (Common Vulnerabilities and Exposures)
- Результати доступні через AWS консоль або CLI
- Можна налаштувати алерти через EventBridge для critical вразливостей

Приклад перегляду результатів:
```bash
aws ecr describe-image-scan-findings \
  --repository-name my-app-repo \
  --image-id imageTag=v1.0.0 \
  --query 'imageScanFindings.findings[?severity==`CRITICAL`]'
```

## Початкове налаштування

### Крок 1: Замініть placeholder значення

У файлі `backend.tf` вкажіть правильну назву S3 bucket, яку створить bootstrap stack:

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket       = "lesson-5-terraform-state-<account-id>"
    key          = "lesson-5/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

### Крок 2: Створіть backend через bootstrap stack

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
cd ..
```

### Крок 3: Ініціалізуйте основний stack на S3 backend

```bash
terraform init -upgrade -reconfigure
```

### Крок 4: Розгорніть основну інфраструктуру

```bash
terraform apply
```

## Використання

### Перевірка конфігурації

```bash
terraform validate
```

### Планування змін

```bash
terraform plan
```

### Застосування змін

```bash
terraform apply
```

### Виведення значень

```bash
terraform output
```

### Видалення інфраструктури

```bash
terraform destroy
```

**⚠️ Увага**: Backend ресурси тепер керуються окремо через `bootstrap/`. Основний `terraform destroy` не видаляє S3 backend bucket і lock resources.

## Безпека

Модуль автоматично налаштовує:
- ✅ Шифрування S3 бакета
- ✅ Блокування публічного доступу до S3
- ✅ Версіювання для відновлення попередніх станів
- ✅ DynamoDB блокування для запобігання одночасних змін

## Рекомендації

1. **Унікальна назва бакета**: S3 бакети мають глобально унікальні імена
2. **Регіон**: Використовуйте регіон, близький до вашої інфраструктури
3. **Теги**: Додавайте теги для організації та відстеження витрат
4. **Backup**: State файли автоматично версіюються, але рекомендується додаткове резервне копіювання

## Корисні команди

```bash
# Форматування коду
terraform fmt -recursive

# Перевірка конфігурації
terraform validate

# Оновлення модулів
terraform get -update

# Перегляд поточного state
terraform show

# Список ресурсів у state
terraform state list

# Детальний output конкретного ресурсу
terraform state show module.vpc.aws_vpc.main

# Графічне відображення інфраструктури
terraform graph | dot -Tsvg > graph.svg

# Перевірка окремого модуля VPC
terraform plan -target=module.vpc

# Виведення специфічного output
terraform output vpc_id
terraform output public_subnet_ids
```

## Тестування мережевої конфігурації

Після розгортання VPC, ви можете перевірити конфігурацію через AWS CLI:

```bash
# Перевірка VPC
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)

# Перевірка підмереж
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"

# Перевірка route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"

# Перевірка Internet Gateway
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$(terraform output -raw vpc_id)"

# Перевірка NAT Gateway
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
```

## Troubleshooting

### S3 Backend

**Помилка: "bucket already exists"**
S3 бакет має глобально унікальну назву. Виберіть іншу назву.

**Помилка: "Error acquiring state lock"**
Інший процес Terraform використовує state. Дочекайтеся завершення або видаліть блокування вручну через DynamoDB консоль (обережно!).

### AWS Credentials

**Помилка: "No valid credential sources found"**
Налаштуйте AWS credentials:
```bash
aws configure
```

### VPC

**Помилка: "availability zones not available"**
Переконайтеся, що вказані зони доступності існують у вашому регіоні:
```bash
aws ec2 describe-availability-zones --region us-west-2
```

**Помилка: "insufficient subnet IPs"**
Збільште CIDR блок або зменшіть кількість підмереж.

### ECR

**Помилка: "denied: Your authorization token has expired"**
Оновіть токен автентифікації:
```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com
```

**Помилка: "AccessDeniedException when scanning image"**
Переконайтеся, що IAM роль має дозвіл `ecr:StartImageScan`.

**Помилка: "Image with tag already exists" (для IMMUTABLE)**
При `image_tag_mutability = "IMMUTABLE"` не можна перезаписувати існуючі теги. Використовуйте унікальні теги (наприклад, git commit hash).

## Безпека та Best Practices

### S3 Backend
- ✅ Версіювання увімкнено для відновлення
- ✅ Шифрування увімкнено
- ✅ Публічний доступ заблоковано
- ⚠️ Рекомендація: увімкніть MFA Delete для production

### VPC
- ✅ 3-зональна архітектура для high availability
- ✅ Приватні підмережі ізольовані від інтернету
- ✅ NAT Gateway для безпечного вихідного трафіку
- ⚠️ Рекомендація: розгляньте VPC Flow Logs для моніторингу

### ECR
- ✅ Автоматичне сканування на вразливості
- ✅ Lifecycle policy для економії витрат
- ✅ Детальна політика доступу
- ⚠️ Рекомендація: використовуйте IMMUTABLE теги для production
- ⚠️ Рекомендація: налаштуйте EventBridge для алертів про критичні вразливості

## Розрахунок витрат

Приблизні щомісячні витрати (us-west-2):

| Сервіс | Опис | Вартість |
|--------|------|----------|
| S3 | State файли (~1 MB) | ~$0.02 |
| DynamoDB | On-demand, блокування | ~$0.00 (мінімальне використання) |
| VPC | Базова інфраструктура | $0.00 |
| NAT Gateway | 24/7 + data transfer | ~$32-45/міс |
| ECR | 10 GB зберігання | ~$1.00 |
| **Разом** | | **~$33-46/міс** |

⚠️ **Найбільша вартість**: NAT Gateway ($0.045/год + $0.045/GB transfer)

**Порада для зменшення витрат**:
- Використовуйте VPC Endpoints для AWS сервісів замість NAT
- Видаляйте старі ECR образи через lifecycle policy
- Вимикайте NAT Gateway для dev оточення коли не використовується

## Додаткова документація

- **[QUICKSTART.md](docs/QUICKSTART.md)** - Швидкий старт з покроковими інструкціями
- **[ENVIRONMENTS.md](docs/ENVIRONMENTS.md)** - Приклади конфігурацій для dev/staging/prod оточень

## Структура проекту

```
devops-ci-cd/
├── README.md              # Головна документація
├── QUICKSTART.md          # Швидкий старт
├── ENVIRONMENTS.md        # Приклади різних оточень
├── main.tf                # Головний файл конфігурації з модулями
├── backend.tf             # Налаштування S3 backend
├── outputs.tf             # Виведення значень з модулів
│
└── modules/               # Terraform модулі
    ├── s3-backend/        # Модуль для S3 та DynamoDB
    │   ├── s3.tf          # S3 бакет з версіюванням
    │   ├── dynamodb.tf    # DynamoDB таблиця для блокування
    │   ├── variables.tf   # Змінні модуля
    │   └── outputs.tf     # Виведення: bucket URL, DynamoDB table name
    │
    ├── vpc/               # Модуль VPC
    │   ├── vpc.tf         # VPC, підмережі, IGW, NAT Gateway
    │   ├── routes.tf      # Route tables та асоціації
    │   ├── variables.tf   # Змінні модуля
    │   └── outputs.tf     # Виведення: VPC ID, subnet IDs, NAT IP
    │
    └── ecr/               # Модуль ECR
        ├── ecr.tf         # ECR репозиторій, lifecycle, політика доступу
        ├── variables.tf   # Змінні модуля
        └── outputs.tf     # Виведення: repository URL, scan status
```

## Ключові особливості реалізації

### ✅ Виконано всі вимоги:

1. **S3 Backend**
   - ✅ S3 бакет для стейт-файлів
   - ✅ Версіювання увімкнено
   - ✅ DynamoDB для блокування
   - ✅ Outputs: URL S3 та ім'я DynamoDB

2. **VPC Infrastructure**
   - ✅ VPC з CIDR блоком
   - ✅ 3 публічні підмережі
   - ✅ 3 приватні підмережі
   - ✅ Internet Gateway
   - ✅ NAT Gateway
   - ✅ Повна маршрутизація через Route Tables

3. **ECR Repository**
   - ✅ Автоматичне сканування образів (scan_on_push)
   - ✅ Політика доступу для репозиторію
   - ✅ URL репозиторію через outputs

### 🎯 Бонусні features:

- 📦 Lifecycle policy для ECR (автоматичне видалення старих образів)
- 🔒 Політика доступу з підтримкою ECS та Lambda
- 🏷️ Система тегів для всіх ресурсів
- 📊 Детальна документація з прикладами
- 🚀 Швидкий старт з готовими командами
- 🌍 Приклади для різних оточень (dev/staging/prod)
- 💰 Розрахунок витрат та рекомендації
- 🔍 Troubleshooting guide
- 📐 Діаграми архітектури
