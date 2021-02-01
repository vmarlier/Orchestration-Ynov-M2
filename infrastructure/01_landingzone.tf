# =============================================================================
# Azure - Project
# =============================================================================

provider "azurerm" {
  features {}
}

locals {
  project_name = terraform.workspace == "prod" ? "ProductionGroupe99" : "DeveloppementGroupe99"

  common_tags = {
  }
}

# =============================================================================
# Azure - Kubernetes
# =============================================================================

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${local.project_name}-KubOrchestrationYnov"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = "${local.project_name}-KubOrchestrationYnov"

  default_node_pool {
    name       = "agentpool"
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
    }
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
    network_policy    = "calico"
  }

  tags = {
    Environment = terraform.workspace,
    service     = "landingzone"
  }

}

# =============================================================================
# Azure - Public IP
# =============================================================================

resource "azurerm_public_ip" "lb_ip" {
  depends_on = [azurerm_kubernetes_cluster.k8s]

  name                = "PublicIPForLB"
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

# =============================================================================
# Azure - Analytics
# =============================================================================

resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "test" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  location            = var.log_analytics_workspace_location
  resource_group_name = azurerm_resource_group.k8s.name
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "test" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.test.location
  resource_group_name   = azurerm_resource_group.k8s.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  workspace_name        = azurerm_log_analytics_workspace.test.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# =============================================================================
# Azure - Container Registry
# =============================================================================

resource "azurerm_container_registry" "acr" {
  name                = "${local.project_name}Cr"
  resource_group_name = azurerm_resource_group.k8s.name
  location            = azurerm_resource_group.k8s.location
  admin_enabled       = false
  sku                 = "Premium"

  tags = {
    Environment = terraform.workspace,
    service     = "landingzone"
  }
}

# =============================================================================
# Azure - Resource Group
# =============================================================================

resource "azurerm_resource_group" "k8s" {
  name     = "${local.project_name}Rg"
  location = var.location
}

# =============================================================================
# Sleep of confirmation
# =============================================================================

resource "time_sleep" "wait_build_infra" {
  depends_on      = [azurerm_kubernetes_cluster.k8s]
  create_duration = "15s"
}
