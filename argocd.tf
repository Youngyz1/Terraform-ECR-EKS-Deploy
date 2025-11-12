########################################################
# Argo CD for GitOps-based deployment management
########################################################

# Create namespace for Argo CD
resource "kubernetes_namespace" "argocd" {
  provider = kubernetes.eks
  metadata {
    name = "argocd"
  }
}

# Generate random password for Argo CD admin user
resource "random_password" "argocd_admin" {
  length  = 16
  special = true
}

# Install Argo CD via Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.46.0"  # Pinned version for stability

  # Set Argo CD server to use LoadBalancer for easy access
  set = [
    {
      name  = "server.service.type"
     value = "ClusterIP"
    },
    {
      name  = "configs.secret.argocdServerAdminPassword"
      value = bcrypt(random_password.argocd_admin.result)
    },
    {
      name  = "redis.resources.requests.cpu"
      value = "100m"
    },
    {
      name  = "redis.resources.requests.memory"
      value = "128Mi"
    },
    {
      name  = "server.resources.requests.cpu"
      value = "100m"
    },
    {
      name  = "server.resources.requests.memory"
      value = "128Mi"
    },
    {
      name  = "repoServer.resources.requests.cpu"
      value = "100m"
    },
    {
      name  = "repoServer.resources.requests.memory"
      value = "128Mi"
    }
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# Get the Argo CD server service to extract LoadBalancer address
data "kubernetes_service" "argocd_server" {
  provider = kubernetes.eks
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  depends_on = [helm_release.argocd]
}
