# Create a new ECR repository
resource "aws_ecr_repository" "service" {
  name = "uchenewwebsit-repo"

  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Authenticate Docker to ECR and push image
resource "null_resource" "push_image" {
  # Rebuild image if Dockerfile or index.html changes
  triggers = {
    dockerfile_sha = filesha256("${path.module}/Dockerfile")
    html_sha       = filesha256("${path.module}/index.html")
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.service.repository_url}
      docker build -t ${aws_ecr_repository.service.repository_url}:latest .
      docker push ${aws_ecr_repository.service.repository_url}:latest
    EOT
  }
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.service.repository_url
}
