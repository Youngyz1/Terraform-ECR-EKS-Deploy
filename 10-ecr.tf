# Try to read an existing ECR repository
data "aws_ecr_repository" "existing" {
  name = "uchenewwebsit-repo"

  # If it doesn't exist, Terraform will continue because we’ll handle it below
  # This requires Terraform 1.3+ where try() can handle failed data lookups
  # If you’re on an older version, we’ll use conditional logic below.
  count = 1
}

# Create a new ECR repository only if it does not already exist
resource "aws_ecr_repository" "service" {
  count                = length(data.aws_ecr_repository.existing) == 0 ? 1 : 0
  name                 = "uchenewwebsit-repo"
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Select the correct repo URL (existing or new)
locals {
  ecr_repo_url = (
    length(data.aws_ecr_repository.existing) > 0 ?
    data.aws_ecr_repository.existing[0].repository_url :
    aws_ecr_repository.service[0].repository_url
  )
}

# Build and push the Docker image
resource "null_resource" "docker_build_push" {
  depends_on = [
    aws_ecr_repository.service
  ]

  triggers = {
    dockerfile_sha = filesha256("${var.docker_context}/Dockerfile")
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.ecr_repo_url}
      docker build -t ${local.ecr_repo_url}:${var.docker_tag} ${var.docker_context}
      docker push ${local.ecr_repo_url}:${var.docker_tag}
    EOT
  }
}

# Output the final image URI
output "image_uri" {
  value = "${local.ecr_repo_url}:${var.docker_tag}"
}
