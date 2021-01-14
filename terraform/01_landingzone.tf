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

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name       = "agentpool"
    node_count = var.agent_count
    vm_size    = "Standard_D2_v2"
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

  tags = {
    Environment = terraform.workspace,
    service     = "landingzone"
  }
}

# =============================================================================
# Azure - Resource Group
# =============================================================================

resource "azurerm_resource_group" "k8s" {
  name     = "local.project_name-rg"
  location = var.location
}
