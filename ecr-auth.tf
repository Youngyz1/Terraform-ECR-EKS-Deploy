# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get ECR auth token for the registry secret
data "aws_ecr_authorization_token" "token" {
  registry_id = data.aws_caller_identity.current.account_id
}

# Create a secret for ECR registry access
resource "kubernetes_secret" "aws_registry" {
  provider = kubernetes.eks
  metadata {
    name = "aws-registry"
    namespace = "default"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${replace(var.image_uri, "/:[^:]+$/", "")}" = {
          "username" = "AWS"
          "password" = data.aws_ecr_authorization_token.token.password
          "email"    = "none"
          "auth"     = base64encode("AWS:${data.aws_ecr_authorization_token.token.password}")
        }
      }
    })
  }
}