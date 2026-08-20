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
# ALZ POLICY NOTE:
#
# The Platform Landing Zone enforces a Deny Azure Policy
# requiring subnets to have a Network Security Group.
#
# For that reason the subnets below are created using
# AzAPI rather than azurerm_subnet.
#
# This allows the subnet + NSG + Route Table association
# to be submitted to Azure in a single ARM request.
# ==========================================================


#
# ----------------------------------------------------------
# App001 Virtual Network
# ----------------------------------------------------------
#

resource "azurerm_virtual_network" "app001" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  address_space = var.virtual_network_address_space

  tags = local.common_tags
}


#
# ==========================================================
# App001 Subnets
# ==========================================================
#
# The three routed subnets are created with BOTH:
#
#   - Network Security Group
#   - App001 spoke Route Table
#
# already attached.
#
# This is necessary so the subnet satisfies the ALZ
# Deny policy at creation time.
#
# ==========================================================


#
# ----------------------------------------------------------
# Workload subnet 01
# ----------------------------------------------------------
#

resource "azapi_resource" "workload_01_subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-01-01"
  name      = var.workload_01_subnet_name
  parent_id = azurerm_virtual_network.app001.id

  body = {
    properties = {
      addressPrefixes = var.workload_01_subnet_prefixes

      networkSecurityGroup = {
        id = azurerm_network_security_group.routed["workload_01"].id
      }

      routeTable = {
        id = azurerm_route_table.spoke.id
      }
    }
  }
}


#
# ----------------------------------------------------------
# Workload subnet 02
# ----------------------------------------------------------
#

resource "azapi_resource" "workload_02_subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-01-01"
  name      = var.workload_02_subnet_name
  parent_id = azurerm_virtual_network.app001.id

  body = {
    properties = {
      addressPrefixes = var.workload_02_subnet_prefixes

      networkSecurityGroup = {
        id = azurerm_network_security_group.routed["workload_02"].id
      }

      routeTable = {
        id = azurerm_route_table.spoke.id
      }
    }
  }
}


#
# ----------------------------------------------------------
# Management / shared-services subnet
# ----------------------------------------------------------
#

resource "azapi_resource" "management_subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-01-01"
  name      = var.management_subnet_name
  parent_id = azurerm_virtual_network.app001.id

  body = {
    properties = {
      addressPrefixes = var.management_subnet_prefixes

      networkSecurityGroup = {
        id = azurerm_network_security_group.routed["management"].id
      }

      routeTable = {
        id = azurerm_route_table.spoke.id
      }
    }
  }
}


#
# ----------------------------------------------------------
# Private Endpoint subnet
# ----------------------------------------------------------
#
# Private Endpoints are deliberately kept in their own
# dedicated subnet.
#
# The standard App001 route table is NOT associated with
# this subnet at this stage.
#
# NSG processing IS enabled for Private Endpoints so that
# the subnet NSG can enforce our explicit access rules.
#
# ----------------------------------------------------------
#

resource "azapi_resource" "private_endpoints_subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-01-01"
  name      = var.private_endpoint_subnet_name
  parent_id = azurerm_virtual_network.app001.id

  body = {
    properties = {
      addressPrefixes = var.private_endpoint_subnet_prefixes

      networkSecurityGroup = {
        id = azurerm_network_security_group.private_endpoints.id
      }

      privateEndpointNetworkPolicies = "NetworkSecurityGroupEnabled"
    }
  }
}