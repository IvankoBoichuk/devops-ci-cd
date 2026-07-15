variable "cluster_name" {
  description = "Назва Kubernetes кластера"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS OIDC provider"
  type        = string
}

variable "namespace" {
  description = "Namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "release_name" {
  description = "Helm release name for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Jenkins chart version"
  type        = string
  default     = "5.9.34"
}

variable "admin_username" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "service_type" {
  description = "Jenkins service type"
  type        = string
  default     = "LoadBalancer"
}

variable "service_port" {
  description = "Jenkins service port"
  type        = number
  default     = 8080
}

variable "storage_class" {
  description = "StorageClass for Jenkins persistence"
  type        = string
  default     = "gp2"
}

variable "storage_size" {
  description = "Persistent volume size for Jenkins"
  type        = string
  default     = "8Gi"
}

variable "controller_cpu_request" {
  description = "CPU request for Jenkins controller"
  type        = string
  default     = "500m"
}

variable "controller_memory_request" {
  description = "Memory request for Jenkins controller"
  type        = string
  default     = "1Gi"
}

variable "controller_cpu_limit" {
  description = "CPU limit for Jenkins controller"
  type        = string
  default     = "1000m"
}

variable "controller_memory_limit" {
  description = "Memory limit for Jenkins controller"
  type        = string
  default     = "2Gi"
}

variable "install_plugins" {
  description = "Jenkins plugins to install"
  type        = list(string)
  default = [
    "kubernetes",
    "workflow-aggregator",
    "git",
    "configuration-as-code",
    "credentials-binding",
    "job-dsl",
  ]
}

variable "bootstrap_pipeline_enabled" {
  description = "Enable Jenkins Configuration as Code bootstrap for credentials and pipeline job"
  type        = bool
  default     = false
}

variable "pipeline_job_name" {
  description = "Name of the Jenkins pipeline job created by JCasC"
  type        = string
  default     = "django-kaniko-pipeline"
}

variable "pipeline_repo_url" {
  description = "Git repository URL containing the Jenkinsfile"
  type        = string
  default     = ""
}

variable "pipeline_repo_branch" {
  description = "Git branch for the pipeline repository"
  type        = string
  default     = "main"
}

variable "pipeline_script_path" {
  description = "Path to Jenkinsfile inside the pipeline repository"
  type        = string
  default     = "Jenkinsfile"
}

variable "pipeline_repo_credentials_id" {
  description = "Credentials ID used by Jenkins to clone the pipeline repository"
  type        = string
  default     = "pipeline-repo-creds"
}

variable "gitops_credentials_id" {
  description = "Credentials ID used by the pipeline to push deployment changes"
  type        = string
  default     = "gitops-repo-creds"
}

variable "git_username" {
  description = "Git username for repository access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "git_token" {
  description = "Git token/password for repository access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ingress_enabled" {
  description = "Enable ingress for Jenkins"
  type        = bool
  default     = false
}

variable "ingress_class_name" {
  description = "Ingress class name for Jenkins"
  type        = string
  default     = "nginx"
}

variable "ingress_host" {
  description = "Ingress host for Jenkins"
  type        = string
  default     = ""
}

variable "ingress_tls_secret_name" {
  description = "TLS secret name for Jenkins ingress"
  type        = string
  default     = "jenkins-tls"
}
