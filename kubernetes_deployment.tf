# DEPRECATED: Deployment is now managed by Argo CD from manifests/production/deployment.yaml
# Terraform will no longer apply/manage this resource; Argo CD will keep it in sync with Git.
# To re-enable Terraform management, uncomment the resource below and remove the argocd-app.tf
#
# resource "kubernetes_deployment" "app" {
#   provider = kubernetes.eks
#   wait_for_rollout = false
#
#   metadata {
#     name      = "uchenewwebsit"
#     namespace = "default"
#   }
#
#   spec {
#     replicas = 2
#
#     selector {
#       match_labels = { app = "uchenewwebsit" }
#     }
#
#     template {
#       metadata {
#         labels = { app = "uchenewwebsit" }
#       }
#
#       spec {
#         container {
#           name  = "uchenewwebsit"
#           image = var.image_uri
#           port { 
#             container_port = 80 
#           }
#           
#           resources {
#             limits = {
#               cpu    = "500m"
#               memory = "512Mi"
#             }
#             requests = {
#               cpu    = "250m"
#               memory = "256Mi"
#             }
#           }
#
#           liveness_probe {
#             http_get {
#               path = "/"
#               port = 80
#             }
#             initial_delay_seconds = 30
#             period_seconds       = 10
#           }
#         }
#         
#         image_pull_secrets {
#           name = "aws-registry"
#         }
#       }
#     }
#   }

# DEPRECATED: Service is now managed by Argo CD from manifests/production/service.yaml
# Terraform will no longer apply/manage this resource; Argo CD will keep it in sync with Git.
#
# resource "kubernetes_service" "app_service" {
#   provider = kubernetes.eks
#   metadata {
#     name      = "uchenewwebsit-service"
#     namespace = "default"
#   }
#
#   spec {
#     selector = {
#       app = "uchenewwebsit"
#     }
#
#     port {
#       port        = 80
#       target_port = 80
#     }
#
#     type = "LoadBalancer"
#   }
# }


