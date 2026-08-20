#
# ==========================================================
# App001 -> Connectivity Hub Peering
# ==========================================================
#
# IMPORTANT:
#
# Azure VNet peering requires a peering resource at BOTH
# ends.
#
# This App001 repository owns only:
#
#     App001 -> Hub
#
# The Platform / Connectivity Terraform should own:
#
#     Hub -> App001
#
# That keeps the Connectivity subscription under Platform
# team ownership.
#
# ==========================================================

resource "azurerm_virtual_network_peering" "app001_to_hub" {
  name = "peer-${var.virtual_network_name}-to-hub"

  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.app001.name

  remote_virtual_network_id = var.hub_virtual_network_id

  allow_virtual_network_access = true

  #
  # Required so that traffic forwarded by the central
  # Azure Firewall/NVA can traverse the peering.
  #
  allow_forwarded_traffic = true

  #
  # There is currently no VPN or ExpressRoute gateway in
  # the Hub, so gateway transit is not required.
  #
  allow_gateway_transit = false
  use_remote_gateways   = false
}