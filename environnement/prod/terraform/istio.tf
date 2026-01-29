resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = "istio-system"
  create_namespace = true  # ADD THIS
  version          = "1.24.2"
  
  timeout = 600  # ADD THIS
  wait    = true # ADD THIS
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  version    = "1.24.2"

  timeout         = 600      # ADD
  wait            = true     # ADD
  cleanup_on_fail = true     # ADD
  atomic          = true     # ADD (rolls back on failure)

  depends_on = [helm_release.istio_base]
  
  values = [
    file("${path.module}/istio-files/istiod.yaml")  
  ]
}

resource "helm_release" "istio_ingress" {
  depends_on = [helm_release.istiod]

  name       = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = "istio-ingress"
  create_namespace = true
  values = [
    file("${path.module}/istio-files/istio-ingress.yaml") # optional
  ]
}
# 4. Kiali (Observability dashboard)
resource "helm_release" "kiali" {
  name       = "kiali"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = "istio-system"
  version    = "2.5.0"

  create_namespace = false

  depends_on = [helm_release.istiod]

  values = [
    file("${path.module}/istio-files/kiali.yaml") # custom Kiali values
  ]
}



# -----------------------
# 5. Prometheus
# -----------------------
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = "istio-system"
  version    = "25.11.0"
  
  timeout         = 600      # ADD
  wait            = true     # ADD
  cleanup_on_fail = true     # ADD
  atomic          = true     # ADD

  depends_on = [
    helm_release.istio_base,  # ADD THIS
    helm_release.istiod
  ]

  values = [
    file("${path.module}/istio-files/prometheus.yaml")
  ]
}

# -----------------------
# 6. Grafana
# -----------------------
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "istio-system"
  version    = "9.7.3"

  depends_on = [helm_release.prometheus]

  values = [
    file("${path.module}/istio-files/grafana.yaml")
  ]
}

# -----------------------
# 7. Jaeger
# -----------------------
resource "helm_release" "jaeger" {
  name       = "jaeger"
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger"
  namespace  = "istio-system"
  version    = "4.2.3"

  create_namespace = false
  depends_on       = [helm_release.istiod]

  values = [
    file("${path.module}/istio-files/jaeger.yaml")
  ]
}
