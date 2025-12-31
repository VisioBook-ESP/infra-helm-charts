output "aks_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_resource_group" {
  description = "AKS resource group"
  value       = azurerm_resource_group.rg.name
}

output "aks_location" {
  description = "AKS location"
  value       = azurerm_resource_group.rg.location
}

output "kubernetes_host" {
  description = "Kubernetes API server endpoint"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive = true
}
output "argocd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}
output "argocd_admin_password" {
  description = "Initial Argo CD admin password"
  value       = data.kubernetes_secret.argocd_admin.data["password"]
  sensitive   = true
}
data "kubernetes_secret" "argocd_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  depends_on = [helm_release.argocd]
}
