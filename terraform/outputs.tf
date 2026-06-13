output "namespace" {
  description = "Namespace Kubernetes déployé"
  value       = kubernetes_namespace.microservice.metadata[0].name
}

output "nacos_service" {
  description = "Service Nacos (DNS interne)"
  value       = "${kubernetes_service.nacos.metadata[0].name}.${var.namespace}.svc.cluster.local:8848"
}

output "gateway_access" {
  description = "Accès au gateway via NodePort (adapter l'IP du nœud selon votre cluster)"
  value       = "http://<NODE_IP>:${var.gateway_node_port}"
}

output "test_endpoints" {
  description = "URLs de test une fois le cluster accessible"
  value = {
    user  = "http://<NODE_IP>:${var.gateway_node_port}/user/1"
    order = "http://<NODE_IP>:${var.gateway_node_port}/order/1"
  }
}
