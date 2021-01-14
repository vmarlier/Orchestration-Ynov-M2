terraform {
  backend "azurerm" {
    resource_group_name  = "DefaultResourceGroup-PAR"
    storage_account_name = "blobtfstateproject"
    container_name       = "tfstatemaj2"
    key                  =  "terraform.tfstate"
  }
}