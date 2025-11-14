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

# ----------------------------------------------------------
# 🧩 AWS & Docker Providers
# ----------------------------------------------------------

provider "aws" {
  region = var.region
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# ----------------------------------------------------------
# 🧩 EKS Cluster Data Sources
# ----------------------------------------------------------

data "aws_eks_cluster" "main" {
  name = try(aws_eks_cluster.main_eks.name, "placeholder")
}

data "aws_eks_cluster_auth" "main" {
  name = try(aws_eks_cluster.main_eks.name, "placeholder")
}

# ----------------------------------------------------------
# 🚧 TEMPORARY PROVIDERS for IMPORT ONLY
# ----------------------------------------------------------
# These use dummy values so Terraform won’t fail during import.
# After import, replace them with the real ones again.
# ----------------------------------------------------------

provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}
