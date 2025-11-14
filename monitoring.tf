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
  version    = "45.0.0" # Pin a stable version for reliability

  # Use the `set` argument (list of maps) to configure Grafana and Prometheus
  set = [
    {
      name  = "grafana.service.type"
      value = "LoadBalancer"   # <-- changed from ClusterIP to LoadBalancer
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

  depends_on = [helm_release.kube_prometheus_stack]
}

# Optional: Output Grafana LoadBalancer DNS
# output "grafana_load_balancer_address" {
#   description = "Grafana LoadBalancer hostname or IP (may be 'pending' until LB is provisioned)"
#   value = try(
#     data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname,
#     data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].ip,
#     "pending"
#   )
# }
