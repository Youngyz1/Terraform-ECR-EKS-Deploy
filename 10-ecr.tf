resource "aws_ecr_repository" "service" {
  name                 = "uchenewwebsit-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
}

resource "null_resource" "docker_build_push" {
  depends_on = [aws_ecr_repository.service]

  triggers = {
    dockerfile_sha = filesha256("${var.docker_context}/Dockerfile")
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.service.repository_url}
      docker build -t ${aws_ecr_repository.service.repository_url}:${var.docker_tag} ${var.docker_context}
      docker push ${aws_ecr_repository.service.repository_url}:${var.docker_tag}
    EOT
  }
}

output "image_uri" {
  value = "${aws_ecr_repository.service.repository_url}:${var.docker_tag}"
}
