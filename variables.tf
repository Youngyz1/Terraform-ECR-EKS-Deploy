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
