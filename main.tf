resource "azurerm_resource_group" "test" {
  name     = "rg-app01-terraform-test"
  location = var.location
}