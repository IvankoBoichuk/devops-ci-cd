# Розгортання фінального стеку в EKS

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

## 4. Застосувати основний Terraform stack

Стек піднімає:
- `VPC`
- `EKS`
- `RDS PostgreSQL`
- `ECR`
- `Jenkins`
- `Argo CD`
- `Prometheus + Grafana`

Потрібні секрети в `terraform.tfvars`:
- `jenkins_admin_password`
- `git_token`
- `rds_db_password`
- `django_secret_key`
- `grafana_admin_password`

```bash
terraform apply
```

## 5. Перевірити namespaces і workloads

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
kubectl get applications -n argocd
kubectl get hpa
```

## 6. Перевірити доступність сервісів

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
kubectl port-forward svc/argocd-server 8081:443 -n argocd
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
```

Після цього відкрийте:
- Jenkins: `http://localhost:8080`
- Argo CD: `https://localhost:8081`
- Grafana: `http://localhost:3000`
- Prometheus: `http://localhost:9090`

Grafana credentials:
- username: `admin`
- password: `terraform output -raw grafana_admin_password`

## 7. Перевірити, що Django використовує RDS

```bash
terraform output rds_endpoint
kubectl get secret django-app-app -o yaml
kubectl get deployment django-app-django -o jsonpath='{.spec.template.spec.containers[0].envFrom}'
echo
```
