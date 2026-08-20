output "app001_resource_group_name" {
  description = "Resource Group containing the App001 network foundation."
  value       = azurerm_resource_group.network.name
}

output "app001_virtual_network_id" {
  description = "Resource ID of the App001 spoke VNet."
  value       = azurerm_virtual_network.app001.id
}

output "app001_virtual_network_name" {
  description = "Name of the App001 spoke VNet."
  value       = azurerm_virtual_network.app001.name
}

output "app001_virtual_network_address_space" {
  description = "Address space assigned to the App001 spoke VNet."
  value       = azurerm_virtual_network.app001.address_space
}

output "workload_01_subnet_id" {
  description = "Resource ID of workload subnet 01."
  value       = azurerm_subnet.workload_01.id
}

output "workload_02_subnet_id" {
  description = "Resource ID of workload subnet 02."
  value       = azurerm_subnet.workload_02.id
}

output "management_subnet_id" {
  description = "Resource ID of the App001 management subnet."
  value       = azurerm_subnet.management.id
}

output "private_endpoint_subnet_id" {
  description = "Resource ID of the App001 Private Endpoint subnet."
  value       = azurerm_subnet.private_endpoints.id
}

output "spoke_route_table_id" {
  description = "Resource ID of the App001 spoke route table."
  value       = azurerm_route_table.spoke.id
}

output "app001_to_hub_peering_id" {
  description = "Resource ID of the App001-to-Hub peering."
  value       = azurerm_virtual_network_peering.app001_to_hub.id
}