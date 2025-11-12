########################################################
# Prometheus + Grafana via Helm (kube-prometheus-stack)
########################################################

# Create a dedicated namespace for monitoring
resource "kubernetes_namespace" "monitoring" {
  provider = kubernetes.eks
  metadata {
    name = "monitoring"
  }
}

# We don't use a separate helm_repository resource because the installed
# helm provider in this Terraform version doesn't support it. Instead
# provide the repository URL directly in the helm_release below.

# Generate a random admin password for Grafana
resource "random_password" "grafana_admin" {
  length  = 16
  special = true
}

# Install kube-prometheus-stack which includes Prometheus and Grafana
resource "helm_release" "kube_prometheus_stack" {
  name       = "monitoring-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  # Use the `set` argument (list of maps) rather than nested set blocks
  set = [
    {
      name  = "grafana.service.type"
     value = "ClusterIP"
    },
    {
      name  = "grafana.adminPassword"
      value = random_password.grafana_admin.result
    },
    {
      name  = "prometheus.prometheusSpec.resources.requests.cpu"
      value = "100m"
    },
    {
      name  = "prometheus.prometheusSpec.resources.requests.memory"
      value = "128Mi"
    }
  ]

  depends_on = [aws_eks_cluster.main_eks]
}

# Expose the Grafana service via a data source so we can output its LB details
data "kubernetes_service" "grafana" {
  provider = kubernetes.eks
  metadata {
    name      = "monitoring-stack-grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  # Wait for helm_release to be created first
  depends_on = [helm_release.kube_prometheus_stack]
}
