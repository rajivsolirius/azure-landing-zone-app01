#
# ==========================================================
# App001 Network Security Groups
# ==========================================================
#
# Security model:
#
#   - deny unnecessary lateral App001 traffic
#   - explicitly permit access to Private Endpoints
#   - permit outbound traffic toward the Hub
#   - allow remaining outbound traffic
#
# IMPORTANT:
#
# "Allow outbound" at the NSG does NOT mean traffic bypasses
# Azure Firewall.
#
# The NSG determines whether traffic may leave the subnet.
#
# The Route Table then determines its next hop.
#
# ==========================================================


#
# ==========================================================
# Workload / Management NSGs
# ==========================================================
#

resource "azurerm_network_security_group" "routed" {
  for_each = local.routed_subnets

  name                = each.value.nsg_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = local.common_tags
}


#
# ----------------------------------------------------------
# INBOUND
#
# Deny traffic originating from elsewhere inside the
# App001 VNet.
#
# Higher-priority explicit allows can be introduced later
# for genuine workload-to-workload requirements.
# ----------------------------------------------------------
#

resource "azurerm_network_security_rule" "deny_app001_inbound" {
  for_each = local.routed_subnets

  name      = "Deny-App001-Inbound"
  priority  = 4000
  direction = "Inbound"
  access    = "Deny"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefixes = var.virtual_network_address_space

  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.routed[each.key].name
}


#
# ----------------------------------------------------------
# OUTBOUND
#
# Explicitly permit HTTPS access to the dedicated Private
# Endpoint subnet.
#
# This rule has a higher priority than the App001-local deny.
#
# ----------------------------------------------------------
#

resource "azurerm_network_security_rule" "allow_private_endpoints_https_outbound" {
  for_each = local.routed_subnets

  name      = "Allow-PrivateEndpoints-HTTPS-Outbound"
  priority  = 100
  direction = "Outbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "443"

  source_address_prefix = "*"

  destination_address_prefixes = var.private_endpoint_subnet_prefixes

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.routed[each.key].name
}


#
# ----------------------------------------------------------
# OUTBOUND
#
# Permit traffic destined for the regional Connectivity Hub.
#
# More-specific VNet peering routes normally cause these
# destinations to use the direct App001 -> Hub peering.
#
# ----------------------------------------------------------
#

resource "azurerm_network_security_rule" "allow_hub_outbound" {
  for_each = local.routed_subnets

  name      = "Allow-Hub-Outbound"
  priority  = 110
  direction = "Outbound"
  access    = "Allow"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefix = "*"

  destination_address_prefixes = var.hub_address_spaces

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.routed[each.key].name
}


#
# ----------------------------------------------------------
# OUTBOUND
#
# Deny traffic from these subnets to other addresses inside
# the App001 VNet.
#
# The Private Endpoint HTTPS exception at priority 100 is
# evaluated before this deny.
#
# ----------------------------------------------------------
#

resource "azurerm_network_security_rule" "deny_app001_outbound" {
  for_each = local.routed_subnets

  name      = "Deny-App001-Outbound"
  priority  = 4000
  direction = "Outbound"
  access    = "Deny"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefix = "*"

  destination_address_prefixes = var.virtual_network_address_space

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.routed[each.key].name
}


#
# ----------------------------------------------------------
# OUTBOUND
#
# Permit remaining traffic.
#
# IMPORTANT:
#
# This does NOT bypass the Hub firewall.
#
# Traffic not matching a more-specific route is subsequently
# matched by:
#
#     0.0.0.0/0 -> Azure Firewall
#
# in the App001 spoke route table.
#
# ----------------------------------------------------------
#

resource "azurerm_network_security_rule" "allow_remaining_outbound" {
  for_each = local.routed_subnets

  name      = "Allow-Remaining-Outbound"
  priority  = 4050
  direction = "Outbound"
  access    = "Allow"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

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
# ----------------------------------------------------------
# PRIVATE ENDPOINT INBOUND
#
# Permit HTTPS from the App001 workload and management
# subnets.
#
# ----------------------------------------------------------
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
# ----------------------------------------------------------
# PRIVATE ENDPOINT INBOUND
#
# Deny all other App001-local inbound traffic.
#
# ----------------------------------------------------------
#

resource "azurerm_network_security_rule" "private_endpoint_deny_app001_inbound" {
  name = "Deny-Other-App001-Inbound"

  priority  = 4000
  direction = "Inbound"
  access    = "Deny"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefixes = var.virtual_network_address_space

  destination_address_prefixes = var.private_endpoint_subnet_prefixes

  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.private_endpoints.name
}