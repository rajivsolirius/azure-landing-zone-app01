#
# ==========================================================
# App001 Spoke Route Table
# ==========================================================
#
# Internet and remote-spoke traffic:
#
#     App001
#        |
#        v
#     0.0.0.0/0
#        |
#        v
#     Azure Firewall
#
# Hub address ranges retain their more-specific VNet
# peering routes and therefore use the direct Hub peering.
#
# No routes are added here for other App001 subnets.
# Same-VNet segmentation is performed with NSGs.
#
# ==========================================================

resource "azurerm_route_table" "spoke" {
  name                = var.route_table_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  #
  # There is currently no VPN/ER gateway in this design.
  # Keeping BGP propagation disabled also ensures dynamically
  # learned routes cannot unexpectedly override the intended
  # forced-egress model in future.
  #
  bgp_route_propagation_enabled = false

  tags = local.common_tags
}


resource "azurerm_route" "default_to_firewall" {
  name = "Default-To-Azure-Firewall"

  resource_group_name = azurerm_resource_group.network.name
  route_table_name    = azurerm_route_table.spoke.name

  address_prefix = "0.0.0.0/0"

  next_hop_type = "VirtualAppliance"

  next_hop_in_ip_address = var.azure_firewall_private_ip_address
}


#
# ----------------------------------------------------------
# Route table associations
# ----------------------------------------------------------
#

resource "azurerm_subnet_route_table_association" "workload_01" {
  subnet_id      = azurerm_subnet.workload_01.id
  route_table_id = azurerm_route_table.spoke.id
}

resource "azurerm_subnet_route_table_association" "workload_02" {
  subnet_id      = azurerm_subnet.workload_02.id
  route_table_id = azurerm_route_table.spoke.id
}

resource "azurerm_subnet_route_table_association" "management" {
  subnet_id      = azurerm_subnet.management.id
  route_table_id = azurerm_route_table.spoke.id
}