# Розгортання Django в EKS

Застосунок не встановлюється на EC2 вручну. EKS створює EC2 worker nodes, Docker-образ
зберігається в ECR, а Kubernetes завантажує його з ECR і запускає через Deployment.

## 1. Підготувати Terraform backend

S3 bucket із `backend.tf` має існувати до першого `terraform init`. Якщо його ще немає,
спочатку тимчасово закоментуйте блок `backend "s3"`, виконайте `terraform init` і
`terraform apply -target=module.s3_backend`. Потім поверніть backend та виконайте:

```bash
terraform init -migrate-state
terraform plan
terraform apply
```

## 2. Розпакувати Django-проєкт і завантажити образ до ECR

```bash
unzip devops-ci-cd-lesson-4.zip
cd devops-ci-cd-lesson-4

AWS_REGION=us-east-1
ECR_URL=$(terraform -chdir=.. output -raw ecr_repository_url)

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "${ECR_URL%%/*}"

docker build -t django-app:latest .
docker tag django-app:latest "$ECR_URL:latest"
docker push "$ECR_URL:latest"
cd ..
```

Архів `devops-ci-cd-lesson-4.zip` і є вихідним кодом Django. Docker build треба запускати
в розпакованому каталозі, де знаходяться `Dockerfile`, `manage.py` і `requirements.txt`.

## 3. Підключити kubectl

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name "$(terraform output -raw eks_cluster_name)"

kubectl get nodes
```

Для HPA в кластері має бути встановлений Metrics Server. Перевірка:

```bash
kubectl top nodes
```

## 4. Встановити Helm chart

Замініть пароль і Django secret key у локальному `charts/django-app/secret-values.yaml`.
Цей файл доданий до `.gitignore` і не повинен потрапляти в Git.

```bash
helm upgrade --install django-app charts/django-app \
  -f charts/django-app/secret-values.yaml \
  --set image.repository="$(terraform output -raw ecr_repository_url)" \
  --set image.tag=latest

kubectl get pods
kubectl get service django-app-django
kubectl get hpa
```

Зовнішня адреса з'явиться в полі `EXTERNAL-IP` сервісу типу LoadBalancer.

## Бонус: Ingress і TLS

Ingress за замовчуванням вимкнений, тому обов'язковий LoadBalancer працює без nginx
Ingress Controller. Для бонусу спочатку встановіть ingress-nginx і cert-manager, а потім
увімкніть `ingress.enabled=true` та задайте власний `ingress.host`.
