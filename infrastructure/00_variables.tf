# =============================================================================
# Variables - Globals
# =============================================================================

variable "location" {
  default = "westeurope"
}

# =============================================================================
# Variables - Kubernetes
# =============================================================================

variable "agent_count" {
  default = 2
}

# =============================================================================
# Variables - Analytics
# =============================================================================

variable "log_analytics_workspace_name" {
  default = "LogsWorkspacek8sDevOrchestrationYnov"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
  default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}
