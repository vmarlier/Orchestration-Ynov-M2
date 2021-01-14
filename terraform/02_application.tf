provider "helm" {
  kubernetes {
    config_path = azurerm_kubernetes_cluster.k8s.kube_config_raw
  }
}

# =============================================================================
# Kubernetes - Traefik2
# =============================================================================

resource "helm_release" "traefik2" {
  depends_on = [azurerm_kubernetes_cluster.k8s]

  name       = "traefik2"
  namespace  = "kube-system"
  repository = "https://containous.github.io/traefik-helm-chart"
  chart      = "traefik"

  values = [file("${path.module}/config/traefik/1-base.yml")]

  /*   templatefile("${path.module}/config/traefik/1-base.yml",
      {
        loadbalancer_ip = scaleway_lb_ip.ip_lb_kapsule.ip_address
      }
    )
  ]*/
}

# =============================================================================
# Kubernetes - Monitoring
# =============================================================================
