#
# ==========================================================
# Standard NSGs
# ==========================================================
#
# These NSGs are used by:
#
# - workload subnet 01
# - workload subnet 02
# - management subnet
#
# General policy:
#
# 1. Permit HTTPS to Private Endpoints.
# 2. Permit outbound traffic to the Hub.
# 3. Deny other App001-local subnet traffic.
# 4. Permit remaining outbound traffic.
#
# The remaining outbound traffic is subsequently subject
# to the subnet's routing table. Therefore Internet and
# remote-spoke traffic will be routed to Azure Firewall.
#
# ==========================================================

resource "azurerm_network_security_group" "routed" {
  for_each = local.routed_subnets

  name                = each.value.nsg_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = local.common_tags
}


#
# ----------------------------------------------------------
# INBOUND:
# Deny traffic originating inside App001's VNet.
#
# Higher-priority explicit allows can be added later.
# ----------------------------------------------------------
#

resource "azurerm_network_security_rule" "deny_app001_inbound" {
  for_each = local.routed_subnets

  name                        = "Deny-App001-Inbound"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = var.virtual_network_address_space
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.routed[each.key].name
}


#
# ----------------------------------------------------------
# OUTBOUND:
# Explicitly allow HTTPS to the Private Endpoint subnet.
#
# This rule must take precedence over the App001-local deny.
# ----------------------------------------------------------
#

resource "azurerm_network_security_rule" "allow_private_endpoints_https_outbound" {
  for_each = local.routed_subnets

  name                         = "Allow-PrivateEndpoints-HTTPS-Outbound"
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "443"
  source_address_prefix        = "*"
  destination_address_prefixes = var.private_endpoint_subnet_prefixes

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.routed[each.key].name
}


#
# ----------------------------------------------------------
# OUTBOUND:
# Explicitly allow traffic towards Hub address ranges.
#
# Routing remains separate from NSG processing.
# ----------------------------------------------------------
#

resource "azurerm_network_security_rule" "allow_hub_outbound" {
  for_each = local.routed_subnets

  name                         = "Allow-Hub-Outbound"
  priority                     = 110
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "*"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = "*"
  destination_address_prefixes = var.hub_address_spaces

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.routed[each.key].name
}


#
# ----------------------------------------------------------
# OUTBOUND:
# Deny other local App001 VNet traffic.
#
# Private Endpoint HTTPS has already been explicitly allowed
# at priority 100.
# ----------------------------------------------------------
#

resource "azurerm_network_security_rule" "deny_app001_outbound" {
  for_each = local.routed_subnets

  name                        = "Deny-App001-Outbound"
  priority                    = 4000
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefixes = var.virtual_network_address_space

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.routed[each.key].name
}


#
# ----------------------------------------------------------
# OUTBOUND:
# Allow everything else.
#
# This does NOT bypass Azure Firewall.
#
# The route table sends destinations without a more-specific
# route to the Azure Firewall using 0.0.0.0/0.
# ----------------------------------------------------------
#

resource "azurerm_network_security_rule" "allow_remaining_outbound" {
  for_each = local.routed_subnets

  name                       = "Allow-Remaining-Outbound"
  priority                   = 5000
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.routed[each.key].name
}


#
# ==========================================================
# Private Endpoint NSG
# ==========================================================
#

resource "azurerm_network_security_group" "private_endpoints" {
  name                = "nsg-app001-private-endpoints"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = local.common_tags
}


#
# Permit App001 workloads/management to connect to Private
# Endpoints using HTTPS.
#
resource "azurerm_network_security_rule" "private_endpoint_https_inbound" {
  name = "Allow-App001-HTTPS-Inbound"

  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "443"

  source_address_prefixes = concat(
    var.workload_01_subnet_prefixes,
    var.workload_02_subnet_prefixes,
    var.management_subnet_prefixes
  )

  destination_address_prefixes = var.private_endpoint_subnet_prefixes

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.private_endpoints.name
}


#
# Deny any other App001-local inbound traffic to the
# Private Endpoint subnet.
#
resource "azurerm_network_security_rule" "private_endpoint_deny_app001_inbound" {
  name = "Deny-Other-App001-Inbound"

  priority  = 4000
  direction = "Inbound"
  access    = "Deny"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefixes      = var.virtual_network_address_space
  destination_address_prefixes = var.private_endpoint_subnet_prefixes

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.private_endpoints.name
}


#
# ----------------------------------------------------------
# NSG associations
# ----------------------------------------------------------
#

resource "azurerm_subnet_network_security_group_association" "workload_01" {
  subnet_id                 = azurerm_subnet.workload_01.id
  network_security_group_id = azurerm_network_security_group.routed["workload_01"].id
}

resource "azurerm_subnet_network_security_group_association" "workload_02" {
  subnet_id                 = azurerm_subnet.workload_02.id
  network_security_group_id = azurerm_network_security_group.routed["workload_02"].id
}

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.routed["management"].id
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
}