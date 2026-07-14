# Backend конфігурація закоментована для початкового розгортання
# Після terraform apply розкоментуйте і виконайте: terraform init -migrate-state

terraform {
  backend "s3" {
    bucket       = "lesson-5-terraform-state-444152780810"
    key          = "lesson-5/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
