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
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}
