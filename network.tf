#
# ==========================================================
# App001 Network Traffic Model
# ==========================================================
#
# App001 -> Hub shared services
#            direct peering
#
# App001 -> Internet
#            Firewall
#
# App001 -> App002
#            Firewall
#
# App001 subnet -> other App001 subnet
#            NSG blocked
#
# App001 workload -> App001 Private Endpoint
#            local VNet + explicit NSG allow
#
# IMPORTANT:
#
# NSGs control whether traffic is permitted.
#
# Route tables control where permitted traffic is sent.
#
# Azure Firewall in the Connectivity Hub performs the
# centralized inspection / allow-deny decision for traffic
# routed to the Hub firewall.
#
# Same-VNet subnet-to-subnet traffic is NOT deliberately
# hairpinned through Azure Firewall in this implementation.
# It is locally segmented using NSGs.
#
# ==========================================================


resource "azurerm_virtual_network" "app001" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  address_space = var.virtual_network_address_space

  tags = local.common_tags
}


#
# ----------------------------------------------------------
# Workload subnet 01
# ----------------------------------------------------------
#

resource "azurerm_subnet" "workload_01" {
  name                 = var.workload_01_subnet_name
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.app001.name

  address_prefixes = var.workload_01_subnet_prefixes
}


#
# ----------------------------------------------------------
# Workload subnet 02
# ----------------------------------------------------------
#

resource "azurerm_subnet" "workload_02" {
  name                 = var.workload_02_subnet_name
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.app001.name

  address_prefixes = var.workload_02_subnet_prefixes
}


#
# ----------------------------------------------------------
# Management / shared-services subnet
# ----------------------------------------------------------
#

resource "azurerm_subnet" "management" {
  name                 = var.management_subnet_name
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.app001.name

  address_prefixes = var.management_subnet_prefixes
}


#
# ----------------------------------------------------------
# Private Endpoint subnet
# ----------------------------------------------------------
#

resource "azurerm_subnet" "private_endpoints" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.app001.name

  address_prefixes = var.private_endpoint_subnet_prefixes

  #
  # Explicitly enable NSG processing for Private Endpoints.
  #
  # We are NOT attaching the general spoke UDR to this
  # subnet at this stage.
  #
  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}