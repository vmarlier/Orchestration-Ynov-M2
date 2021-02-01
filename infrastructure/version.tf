terraform {
  required_providers {
    # azurerm = {
    #   source  = "hashicorp/azurerm"
    #   version = "2.42.0"
    #   features {}

    # }
    helm = {
      source  = "hashicorp/helm"
      version = "2.0.1"
    }
  }
  required_version = "~> 0.14"
}
