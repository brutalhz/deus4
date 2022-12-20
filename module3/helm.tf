resource "kubernetes_namespace" "opencart" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "opencart" {
  chart      = "opencart"
  name       = "opencart"
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  depends_on = [
    yandex_kubernetes_node_group.k8s_node_group
  ]
}


