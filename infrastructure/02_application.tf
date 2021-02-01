provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
    token                  = azurerm_kubernetes_cluster.k8s.kube_config.0.password
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  token                  = azurerm_kubernetes_cluster.k8s.kube_config.0.password
}

# =============================================================================
# Kubernetes - Namespaces
# =============================================================================

resource "kubernetes_namespace" "project_namespace" {
  depends_on = [time_sleep.wait_build_infra]
  metadata {
    name = "project"
    labels = {
      role = "project"
    }
  }
  timeouts { delete = "5m" }
}

resource "kubernetes_namespace" "database_namespace" {
  depends_on = [time_sleep.wait_build_infra]
  metadata {
    name = "database"
    labels = {
      role = "database"
    }
  }
  timeouts { delete = "5m" }
}

# tag the kube-system ns
resource "null_resource" "labelized_kube_system" {
  depends_on = [time_sleep.wait_build_infra]

  provisioner "local-exec" {
    command     = "kubectl label namespace kube-system name=kube-system --kubeconfig <(echo $KUBECONFIG | base64 -d)"
    interpreter = ["/bin/bash", "-c"]

    environment = { KUBECONFIG = base64encode(azurerm_kubernetes_cluster.k8s.kube_config_raw) }
  }
}

# =============================================================================
# Kubernetes - Traefik2
# =============================================================================

resource "helm_release" "traefik2" {
  depends_on = [time_sleep.wait_build_infra]

  name       = "traefik2"
  namespace  = "kube-system"
  repository = "https://containous.github.io/traefik-helm-chart"
  chart      = "traefik"

  values = [
    templatefile("${path.module}/config/traefik/1-base.yml",
      {
        loadbalancer_ip = azurerm_public_ip.lb_ip.ip_address
      }
    )
  ]
}

# =============================================================================
# Kubernetes - TLS
# =============================================================================

resource "kubernetes_secret" "traefik-cert" {
  depends_on = [kubernetes_namespace.project_namespace]
  metadata {
    name      = "traefik-cert"
    namespace = kubernetes_namespace.project_namespace.metadata[0].name
  }
  data = {
    "tls.crt" = file("${path.module}/certs/certificate.crt")
    "tls.key" = file("${path.module}/certs/private.key")
  }
  type = "kubernetes.io/tls"
}
