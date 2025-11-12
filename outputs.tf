output "grafana_admin_password" {
  description = "Generated Grafana admin password (sensitive)"
  value       = random_password.grafana_admin.result
  sensitive   = true
}

output "grafana_load_balancer_address" {
  description = "Grafana LoadBalancer hostname or IP (may be 'pending' until LB is provisioned)"
  value = try(
    data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname,
    data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].ip,
    "pending"
  )
}

output "argocd_admin_password" {
  description = "Argo CD admin password (sensitive)"
  value       = random_password.argocd_admin.result
  sensitive   = true
}

output "argocd_server_address" {
  description = "Argo CD server LoadBalancer address (may be 'pending' until LB is provisioned)"
  value = try(
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname,
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].ip,
    "pending"
  )
}

