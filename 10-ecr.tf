# Import existing ECR repository or create new one
# The repository likely already exists from previous deploys
# If you need to recreate it, manually delete it from AWS first

# Commented out - repository already exists in AWS
# Uncomment and run: terraform import aws_ecr_repository.service uchenewwebsit-repo

# resource "aws_ecr_repository" "service" {
#   name                 = "uchenewwebsit-repo"
#   force_delete         = true
#   image_tag_mutability = "MUTABLE"
#
#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

# Data source to reference the existing ECR repository
data "aws_ecr_repository" "service" {
  name = "uchenewwebsit-repo"
}

locals {
  ecr_repo_url = data.aws_ecr_repository.service.repository_url
}

# Build and push the Docker image
resource "null_resource" "docker_build_push" {
  depends_on = [
    data.aws_ecr_repository.service
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
