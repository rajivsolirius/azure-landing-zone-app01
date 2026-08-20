#
# ==========================================================
# App001 Spoke Route Table
# ==========================================================
#
# Traffic model:
#
# App001 -> Hub shared services
#            direct peering
#
# App001 -> Internet
#            Azure Firewall
#
# App001 -> App002
#            Azure Firewall
#
# App001 subnet -> other App001 subnet
#            NSG blocked
#
# App001 workload -> App001 Private Endpoint
#            local VNet + explicit NSG allow
#
#
# The default route below forces destinations without a
# more-specific route toward the central Azure Firewall.
#
# Hub prefixes continue to have more-specific VNet peering
# routes and therefore use the direct Hub peering.
#
# No routes are added here for other App001 subnets.
#
# Same-VNet segmentation is performed by NSGs.
#
# ==========================================================


resource "azurerm_route_table" "spoke" {
  name                = var.route_table_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  #
  # There is currently no VPN or ExpressRoute gateway in
  # this regional Hub design.
  #
  # Disabling BGP route propagation also prevents future
  # dynamically learned routes from unexpectedly changing
  # the intended forced-egress model.
  #
  bgp_route_propagation_enabled = false

  tags = local.common_tags
}


#
# ----------------------------------------------------------
# Default route -> Hub Azure Firewall
# ----------------------------------------------------------
#

resource "azurerm_route" "default_to_firewall" {
  name = "Default-To-Azure-Firewall"

  resource_group_name = azurerm_resource_group.network.name
  route_table_name    = azurerm_route_table.spoke.name

  address_prefix = "0.0.0.0/0"

  next_hop_type = "VirtualAppliance"

  next_hop_in_ip_address = var.azure_firewall_private_ip_address
}