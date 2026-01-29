resource "kubernetes_namespace" "argocd" {
  depends_on = [azurerm_kubernetes_cluster.aks]

  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "istio_system" {
  depends_on = [azurerm_kubernetes_cluster.aks]

  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace" "istio_ingress" {
  depends_on = [azurerm_kubernetes_cluster.aks]

  metadata {
    name = "istio-ingress"
  }
}
