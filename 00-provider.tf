terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.18.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.0.0"
    }
  }

  backend "s3" {
    bucket         = "youngyz-terraform-state"
    key            = "full-stack/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

# ----------------------------------------
# 🧩 AWS & Docker Providers
# ----------------------------------------

provider "aws" {
  region = var.region
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# ----------------------------------------
# 🧩 EKS Data Sources (Cluster & Auth)
# ----------------------------------------
# These must be declared *after* the EKS cluster is created.
# Do NOT use them directly in provider blocks at initialization time.
data "aws_eks_cluster" "main" {
  name = aws_eks_cluster.main_eks.name
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main_eks.name
}
# ----------------------------------------
# Configure Kubernetes & Helm providers to talk to the EKS cluster
# DISABLED during cleanup - will re-enable after resources are destroyed
# ----------------------------------------
# provider "kubernetes" {
#   host                   = aws_eks_cluster.main_eks.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.main.token
#   alias                  = "eks"
# }
#
# provider "helm" {
#   kubernetes = {
#     host                   = aws_eks_cluster.main_eks.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.main.token
#   }
# }
provider "kubernetes" {
  host                   = aws_eks_cluster.main_eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
  alias                  = "eks"

  # Add resilience: skip validation if cluster is being destroyed
  skip_credentials_validation = false
  skip_metadata_api_check     = false
}

provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.main_eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}
