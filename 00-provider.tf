terraform {
  backend "s3" {
    bucket         = "youngyz-terraform-state"
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

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
  }
}

#########################################
# PROVIDERS
#########################################

provider "aws" {
  region = var.region
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main_eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main_eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main_eks.token
}
