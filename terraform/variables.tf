variable "kubeconfig_path" {
  description = "Chemin vers le fichier kubeconfig"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Contexte Kubernetes à utiliser (vide = contexte par défaut)"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "Namespace Kubernetes pour les microservices"
  type        = string
  default     = "microservice"
}

variable "nacos_image" {
  description = "Image Docker de Nacos"
  type        = string
  default     = "nacos/nacos-server:v2.2.0"
}

variable "gateway_image" {
  description = "Image Docker du gateway"
  type        = string
  default     = "microservice/gateway-server:latest"
}

variable "user_image" {
  description = "Image Docker du user-service"
  type        = string
  default     = "microservice/user-service:latest"
}

variable "order_image" {
  description = "Image Docker du order-service"
  type        = string
  default     = "microservice/order-service:latest"
}

variable "image_pull_policy" {
  description = "Politique de pull des images (IfNotPresent pour clusters locaux)"
  type        = string
  default     = "IfNotPresent"
}

variable "gateway_node_port" {
  description = "Port NodePort exposé pour le gateway"
  type        = number
  default     = 30080
}

variable "nacos_server_addr" {
  description = "Adresse Nacos utilisée par les microservices"
  type        = string
  default     = "nacos.microservice.svc.cluster.local:8848"
}
