# =============================================================================
# Kubernetes - Namespaces
# =============================================================================

resource "kubernetes_namespace" "monitoring_namespace" {
  depends_on = [time_sleep.wait_build_infra]
  metadata {
    name = "monitoring"
    labels = {
      role = "monitoring"
    }
  }
  timeouts { delete = "5m" }
}

# =============================================================================
# Kubernetes - Prometheus
# =============================================================================

resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace.monitoring_namespace]

  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "13.2.1"

  values = [file("${path.module}/config/prometheus/prometheus.yaml")]
}

# =============================================================================
# Kubernetes - Loki
# =============================================================================

resource "helm_release" "loki" {
  depends_on = [helm_release.prometheus]

  name       = "loki"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "2.3.0"

  values = [file("${path.module}/config/loki/loki.yaml")]
}

# =============================================================================
# Kubernetes - Promtail
# =============================================================================

resource "helm_release" "promtail" {
  depends_on = [helm_release.loki]

  name       = "promtail"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "3.0.4"

  values = [file("${path.module}/config/promtail/promtail.yaml")]
}

# =============================================================================
# Kubernetes - Grafana
# =============================================================================

resource "helm_release" "grafana" {
  depends_on = [helm_release.promtail]

  name       = "grafana"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.2.1"

  values = [file("${path.module}/config/grafana/grafana.yaml")]
}

# =============================================================================
# Kubernetes - Create IngressRoute for grafana
# =============================================================================

resource "null_resource" "grafana_ingress" {
  triggers = {
    ingress_file_sha1 = sha1(file("${path.module}/config/grafana/monitoring-grafana-ingressroute.yml"))
    kubeconfig        = base64encode(azurerm_kubernetes_cluster.k8s.kube_config_raw)
  }
  depends_on = [helm_release.grafana]
  provisioner "local-exec" {
    command     = "kubectl apply -f config/grafana/monitoring-grafana-ingressroute.yml --kubeconfig <(echo $KUBECONFIG | base64 -d)"
    interpreter = ["/bin/bash", "-c"]

    environment = { KUBECONFIG = base64encode(azurerm_kubernetes_cluster.k8s.kube_config_raw) }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "kubectl delete -f config/grafana/monitoring-grafana-ingressroute.yml --kubeconfig <(echo $KUBECONFIG | base64 -d)"
    interpreter = ["/bin/bash", "-c"]

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}

# =============================================================================
# Kubernetes - Rabbitmq node exporter
# =============================================================================

resource "helm_release" "rabbitmq_exporter" {
  depends_on = [helm_release.prometheus]

  name       = "rabbitmq_exporter"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-rabbitmq-exporter"
  version    = "0.6.0"

  values = [file("${path.module}/config/rabbitmq_exporter/rabbitmq_exporter.yaml")]
}
