variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "main_vpc" {
  description = "Name of the main VPC"
  type        = string
  default     = "main_vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "main_eks"
}

variable "docker_context" {
  description = "Path to the Dockerfile directory"
  type        = string
  default     = "./app"
}

variable "docker_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}
variable "image_uri" {
  description = "Docker image URI"
  type        = string
}
