variable "project_name" {
  type        = map
  description = "kub"
  default     = {
    dev  = "DeveloppementGroupe99"
    prod = "ProductionGroupe99"
  }
}

variable "env" {
  description = "env: dev or prod"
}



variable "agent_count" {
    default = 1
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable location {
    default = "westeurope"
}

variable log_analytics_workspace_name {
    default = "LogsWorkspacek8sDevOrchestrationYnov"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "eastus"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}