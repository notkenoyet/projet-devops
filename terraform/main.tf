resource "kubernetes_namespace" "microservice" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/part-of" = "microservice"
      "managed-by"                = "terraform"
    }
  }
}

resource "kubernetes_deployment" "nacos" {
  metadata {
    name      = "nacos"
    namespace = kubernetes_namespace.microservice.metadata[0].name
    labels = {
      app = "nacos"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nacos"
      }
    }

    template {
      metadata {
        labels = {
          app = "nacos"
        }
      }

      spec {
        container {
          name  = "nacos"
          image = var.nacos_image

          port {
            container_port = 8848
          }
          port {
            container_port = 9848
          }

          env {
            name  = "MODE"
            value = "standalone"
          }
          env {
            name  = "JVM_XMS"
            value = "256m"
          }
          env {
            name  = "JVM_XMX"
            value = "256m"
          }

          readiness_probe {
            http_get {
              path = "/nacos/"
              port = 8848
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nacos" {
  metadata {
    name      = "nacos"
    namespace = kubernetes_namespace.microservice.metadata[0].name
    labels = {
      app = "nacos"
    }
  }

  spec {
    selector = {
      app = "nacos"
    }

    port {
      name        = "http"
      port        = 8848
      target_port = 8848
    }

    port {
      name        = "grpc"
      port        = 9848
      target_port = 9848
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "user_service" {
  metadata {
    name      = "user-service"
    namespace = kubernetes_namespace.microservice.metadata[0].name
    labels = {
      app = "user-service"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "user-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "user-service"
        }
      }

      spec {
        container {
          name              = "user-service"
          image             = var.user_image
          image_pull_policy = var.image_pull_policy

          port {
            container_port = 8081
          }

          env {
            name  = "NACOS_SERVER_ADDR"
            value = var.nacos_server_addr
          }

          readiness_probe {
            tcp_socket {
              port = 8081
            }
            initial_delay_seconds = 40
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.nacos]
}

resource "kubernetes_service" "user_service" {
  metadata {
    name      = "user-service"
    namespace = kubernetes_namespace.microservice.metadata[0].name
  }

  spec {
    selector = {
      app = "user-service"
    }

    port {
      port        = 8081
      target_port = 8081
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "order_service" {
  metadata {
    name      = "order-service"
    namespace = kubernetes_namespace.microservice.metadata[0].name
    labels = {
      app = "order-service"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "order-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "order-service"
        }
      }

      spec {
        container {
          name              = "order-service"
          image             = var.order_image
          image_pull_policy = var.image_pull_policy

          port {
            container_port = 8082
          }

          env {
            name  = "NACOS_SERVER_ADDR"
            value = var.nacos_server_addr
          }

          readiness_probe {
            tcp_socket {
              port = 8082
            }
            initial_delay_seconds = 40
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment.nacos,
    kubernetes_deployment.user_service,
  ]
}

resource "kubernetes_service" "order_service" {
  metadata {
    name      = "order-service"
    namespace = kubernetes_namespace.microservice.metadata[0].name
  }

  spec {
    selector = {
      app = "order-service"
    }

    port {
      port        = 8082
      target_port = 8082
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "gateway_server" {
  metadata {
    name      = "gateway-server"
    namespace = kubernetes_namespace.microservice.metadata[0].name
    labels = {
      app = "gateway-server"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "gateway-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "gateway-server"
        }
      }

      spec {
        container {
          name              = "gateway-server"
          image             = var.gateway_image
          image_pull_policy = var.image_pull_policy

          port {
            container_port = 8080
          }

          env {
            name  = "NACOS_SERVER_ADDR"
            value = var.nacos_server_addr
          }

          readiness_probe {
            tcp_socket {
              port = 8080
            }
            initial_delay_seconds = 45
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment.nacos,
    kubernetes_deployment.user_service,
    kubernetes_deployment.order_service,
  ]
}

resource "kubernetes_service" "gateway_server" {
  metadata {
    name      = "gateway-server"
    namespace = kubernetes_namespace.microservice.metadata[0].name
  }

  spec {
    selector = {
      app = "gateway-server"
    }

    port {
      port        = 8080
      target_port = 8080
      node_port   = var.gateway_node_port
    }

    type = "NodePort"
  }
}
