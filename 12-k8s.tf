resource "kubernetes_deployment" "app" {
  metadata {
    name      = "uchenewwebsit"
    namespace = "default"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "uchenewwebsit"
      }
    }

    template {
      metadata {
        labels = {
          app = "uchenewwebsit"
        }
      }

      spec {
        container {
          name  = "uchenewwebsit"
          image = var.image_uri
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_service" {
  metadata {
    name      = "uchenewwebsit-service"
    namespace = "default"
  }

  spec {
    selector = {
      app = "uchenewwebsit"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
