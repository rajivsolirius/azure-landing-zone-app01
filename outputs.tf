#
# ==========================================================
# App001 Network Foundation Outputs
# ==========================================================
#

output "app001_resource_group_name" {
  description = "Resource Group containing the App001 network foundation."

  value = azurerm_resource_group.network.name
}


output "app001_virtual_network_id" {
  description = "Resource ID of the App001 spoke VNet."

  value = azurerm_virtual_network.app001.id
}


output "app001_virtual_network_name" {
  description = "Name of the App001 spoke VNet."

  value = azurerm_virtual_network.app001.name
}


output "app001_virtual_network_address_space" {
  description = "Address space assigned to the App001 spoke VNet."

  value = azurerm_virtual_network.app001.address_space
}


#
# ----------------------------------------------------------
# Subnets
# ----------------------------------------------------------
#

output "workload_01_subnet_id" {
  description = "Resource ID of App001 workload subnet 01."

  value = azapi_resource.workload_01_subnet.id
}


output "workload_02_subnet_id" {
  description = "Resource ID of App001 workload subnet 02."

  value = azapi_resource.workload_02_subnet.id
}


output "management_subnet_id" {
  description = "Resource ID of the App001 management/shared-services subnet."

  value = azapi_resource.management_subnet.id
}


output "private_endpoint_subnet_id" {
  description = "Resource ID of the dedicated App001 Private Endpoint subnet."

  value = azapi_resource.private_endpoints_subnet.id
}


#
# ----------------------------------------------------------
# Route table
# ----------------------------------------------------------
#

output "spoke_route_table_id" {
  description = "Resource ID of the App001 spoke route table."

  value = azurerm_route_table.spoke.id
}


#
# ----------------------------------------------------------
# Peering
# ----------------------------------------------------------
#

output "app001_to_hub_peering_id" {
  description = "Resource ID of the App001-to-Hub VNet peering."

  value = azurerm_virtual_network_peering.app001_to_hub.id
}