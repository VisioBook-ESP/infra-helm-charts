resource "helm_release" "argocd" {
  depends_on = [
    azurerm_kubernetes_cluster.aks,
    kubernetes_namespace.argocd
  ]
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.3"

  wait    = true
  timeout = 600
}
