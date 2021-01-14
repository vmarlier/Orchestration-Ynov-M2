resource "azurerm_resource_group" "k8s" {
    name     = "${lookup(var.project_name, var.env)}-rg"
    location = var.location
}