# Швидкий старт

## Крок 1: Підготовка

```bash
# Клонуйте репозиторій або перейдіть в директорію проекту
cd devops-ci-cd

# Переконайтеся, що AWS CLI налаштовано
aws sts get-caller-identity

# Встановіть Terraform (якщо ще не встановлено)
# https://www.terraform.io/downloads
terraform version
```

## Крок 2: Налаштування змінних

Відредагуйте `main.tf` та `backend.tf`:

```bash
# Замініть "ваше ім'я" на унікальну назву бакета
# Наприклад: "mycompany-terraform-state-123456"
sed -i 's/ваше ім'"'"'я/your-unique-bucket-name/g' main.tf backend.tf
```

Або вручну:
- У `main.tf` рядок 4: `bucket_name = "your-unique-bucket-name"`
- У `backend.tf` рядок 3: `bucket = "your-unique-bucket-name"`

## Крок 3: Перше розгортання (створення S3 та DynamoDB)

```bash
# Закоментуйте backend конфігурацію
sed -i '1,7s/^/#/' backend.tf

# Ініціалізація Terraform
terraform init

# Перегляд змін
terraform plan

# Застосування змін
terraform apply -auto-approve
```

## Крок 4: Міграція State до S3

```bash
# Розкоментуйте backend
sed -i '1,7s/^#//' backend.tf

# Міграція state до S3
terraform init -migrate-state

# Підтвердіть міграцію введенням "yes"
```

## Крок 5: Перевірка інфраструктури

```bash
# Виведення всіх outputs
terraform output

# Перевірка VPC
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)

# Перевірка ECR
aws ecr describe-repositories --repository-names $(terraform output -raw ecr_repository_name)

# Список всіх ресурсів
terraform state list
```

## Крок 6: Робота з ECR

```bash
# Аутентифікація в ECR
aws ecr get-login-password --region us-west-2 | \
  docker login --username AWS --password-stdin \
  $(terraform output -raw ecr_repository_url | cut -d/ -f1)

# Приклад: Build та Push образу
docker build -t my-app:v1.0.0 .
docker tag my-app:v1.0.0 $(terraform output -raw ecr_repository_url):v1.0.0
docker push $(terraform output -raw ecr_repository_url):v1.0.0
```

## Видалення інфраструктури

```bash
# УВАГА: Це видалить всю інфраструктуру!

# Спочатку очистіть ECR репозиторій
aws ecr batch-delete-image \
  --repository-name $(terraform output -raw ecr_repository_name) \
  --image-ids "$(aws ecr list-images \
    --repository-name $(terraform output -raw ecr_repository_name) \
    --query 'imageIds[*]' --output json)"

# Видалення інфраструктури
terraform destroy -auto-approve

# Після цього вручну видаліть S3 бакет (якщо потрібно)
aws s3 rb s3://your-unique-bucket-name --force
```

## Типові проблеми

### "bucket already exists"
Назва бакета вже зайнята. Змініть на іншу унікальну назву.

### "No valid credential sources"
```bash
aws configure
# Введіть AWS Access Key ID та Secret Access Key
```

### "Error acquiring state lock"
```bash
# Зачекайте завершення іншого процесу або видаліть lock
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID": {"S": "your-bucket-name/lesson-5/terraform.tfstate"}}'
```

## Корисні команди

```bash
# Форматування коду
terraform fmt -recursive

# Валідація
terraform validate

# Графічне відображення
terraform graph | dot -Tsvg > infrastructure.svg

# Імпорт існуючого ресурсу
terraform import module.vpc.aws_vpc.main vpc-12345678

# Видалення конкретного ресурсу
terraform destroy -target=module.ecr
```

## Наступні кроки

1. **Запустіть повний smoke test** через `terraform apply` і `kubectl get all -n jenkins|argocd|monitoring`
2. **Перевірте port-forward доступ** до Jenkins, Argo CD, Grafana і Prometheus
3. **Підтвердіть роботу RDS** через `terraform output rds_endpoint` і env-конфіг Deployment
4. **Додайте alerting** для Grafana/Prometheus під ваші demo-сценарії
5. **Підготуйте коротку demo-послідовність** Jenkins -> ECR -> Argo CD -> Grafana

Дивіться [README.md](README.md) для детальної документації.
