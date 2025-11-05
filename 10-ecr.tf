############################################
# CREATE ECR REPOSITORY
############################################
resource "aws_ecr_repository" "service" {
  name                 = "uchenewwebsit-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

############################################
# BUILD AND PUSH DOCKER IMAGE TO ECR
############################################
resource "null_resource" "build_and_push" {
  depends_on = [aws_ecr_repository.service]

  # Re-run if files change
  triggers = {
    dockerfile_sha = filesha256("${path.module}/Dockerfile")
    html_sha       = filesha256("${path.module}/index.html")
  }

  provisioner "local-exec" {
    command     = <<EOT
      $ErrorActionPreference = "Stop"
      $pass = aws ecr get-login-password --region ${var.region}
      docker login --username AWS --password $pass ${aws_ecr_repository.service.repository_url}
      docker build -t ${aws_ecr_repository.service.repository_url}:latest .
      docker push ${aws_ecr_repository.service.repository_url}:latest
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}

############################################
# OUTPUT
############################################
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.service.repository_url
}
