#
# ----------------------------------------------------------
# Subscription / Region
# ----------------------------------------------------------
#

variable "subscription_id" {
  description = "Subscription ID for Application Landing Zone App001."
  type        = string
}

variable "location" {
  description = "Azure region for App001."
  type        = string
  default     = "uksouth"
}


#
# ----------------------------------------------------------
# Naming
# ----------------------------------------------------------
#

variable "resource_group_name" {
  description = "Resource Group containing the App001 network foundation."
  type        = string
  default     = "rg-app001-network-uks-001"
}

variable "virtual_network_name" {
  description = "Name of the App001 spoke Virtual Network."
  type        = string
  default     = "vnet-app001-uks-001"
}

variable "route_table_name" {
  description = "Name of the shared App001 spoke route table."
  type        = string
  default     = "rt-app001-uks-001"
}


#
# ----------------------------------------------------------
# App001 VNet address space
# ----------------------------------------------------------
#

variable "virtual_network_address_space" {
  description = "Address space assigned to the App001 spoke VNet."
  type        = list(string)

  default = [
    "10.50.0.0/16"
  ]
}


#
# ----------------------------------------------------------
# Workload subnet 01
# ----------------------------------------------------------
#

variable "workload_01_subnet_name" {
  description = "Name of workload subnet 01."
  type        = string
  default     = "snet-app001-workload-01"
}

variable "workload_01_subnet_prefixes" {
  description = "Address prefixes assigned to workload subnet 01."
  type        = list(string)

  default = [
    "10.50.1.0/24"
  ]
}


#
# ----------------------------------------------------------
# Workload subnet 02
# ----------------------------------------------------------
#

variable "workload_02_subnet_name" {
  description = "Name of workload subnet 02."
  type        = string
  default     = "snet-app001-workload-02"
}

variable "workload_02_subnet_prefixes" {
  description = "Address prefixes assigned to workload subnet 02."
  type        = list(string)

  default = [
    "10.50.2.0/24"
  ]
}


#
# ----------------------------------------------------------
# Management / shared services subnet
# ----------------------------------------------------------
#

variable "management_subnet_name" {
  description = "Name of the App001 management/shared-services subnet."
  type        = string
  default     = "snet-app001-management"
}

variable "management_subnet_prefixes" {
  description = "Address prefixes assigned to the management/shared-services subnet."
  type        = list(string)

  default = [
    "10.50.10.0/24"
  ]
}


#
# ----------------------------------------------------------
# Private Endpoint subnet
# ----------------------------------------------------------
#

variable "private_endpoint_subnet_name" {
  description = "Dedicated subnet used by App001 Private Endpoints."
  type        = string
  default     = "snet-app001-private-endpoints"
}

variable "private_endpoint_subnet_prefixes" {
  description = "Address prefixes assigned to the Private Endpoint subnet."
  type        = list(string)

  default = [
    "10.50.20.0/24"
  ]
}


#
# ----------------------------------------------------------
# Hub / Azure Firewall
# ----------------------------------------------------------
#

variable "hub_virtual_network_id" {
  description = "Full Azure resource ID of the regional Connectivity Hub VNet."
  type        = string
}

variable "hub_address_spaces" {
  description = "CIDR ranges belonging to the regional Connectivity Hub VNet."
  type        = list(string)
}

variable "azure_firewall_private_ip_address" {
  description = "Private IP address of the central Azure Firewall in the Connectivity Hub."
  type        = string
}


#
# ----------------------------------------------------------
# Tags
# ----------------------------------------------------------
#

variable "subscription_name" {
  description = "Friendly name of the App001 subscription."
  type        = string
}

variable "tenant_name" {
  description = "Friendly tenant name used for tagging."
  type        = string
}

variable "workload_name" {
  description = "Application/workload identifier."
  type        = string
  default     = "TBD"
}