terraform {
  backend "azurerm" {
    resource_group_name  = "DefaultResourceGroup-PAR"
    storage_account_name = "blobtfstateproject"
    container_name       = "tfstatemaj2"
    key                  =  "terraform.tfstate"
    #key                  =  "3g4wbpahb5D9vBWqrDKElDDZpAukyzyGOYQKLJD9EGHwDFbAOHFRmbtwd/hWbzkjrEVjSwid/Q08pvFvKYgG5w=="
  }
}