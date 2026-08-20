#
# ----------------------------------------------------------
# App001 network
# ----------------------------------------------------------
#

virtual_network_address_space = [
  "10.50.0.0/16"
]

workload_01_subnet_prefixes = [
  "10.50.1.0/24"
]

workload_02_subnet_prefixes = [
  "10.50.2.0/24"
]

management_subnet_prefixes = [
  "10.50.10.0/24"
]

private_endpoint_subnet_prefixes = [
  "10.50.20.0/24"
]


#
# ----------------------------------------------------------
# Connectivity Hub
# ----------------------------------------------------------
#

hub_virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/REPLACE-HUB-RG/providers/Microsoft.Network/virtualNetworks/REPLACE-HUB-VNET"

hub_address_spaces = [
  "10.0.0.0/16"
]

azure_firewall_private_ip_address = "10.0.1.4"


#
# ----------------------------------------------------------
# Tags
# ----------------------------------------------------------
#

subscription_name = "App001"
tenant_name       = "TENANT-NAME"
workload_name     = "TBD"