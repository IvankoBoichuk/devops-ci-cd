# Основний stack використовує вже створений S3 backend.
# Backend ресурси створюються окремо через каталог bootstrap/.

terraform {
  backend "s3" {
    bucket       = "lesson-5-terraform-state-444152780810"
    key          = "lesson-5/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
