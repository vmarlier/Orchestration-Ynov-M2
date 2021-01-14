resource "azurerm_container_registry" "acr" {
  name                     = "${lookup(var.project_name, var.env)}Cr"
  resource_group_name      = azurerm_resource_group.k8s.name
  location                 = azurerm_resource_group.k8s.location
  admin_enabled            = false
}