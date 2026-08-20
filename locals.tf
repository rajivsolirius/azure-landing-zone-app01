locals {
  common_tags = {
    SubscriptionName = var.subscription_name
    TenantName       = var.tenant_name
    ResourceGroup    = var.resource_group_name
    Workload         = var.workload_name
  }

  routed_subnets = {
    workload_01 = {
      name     = var.workload_01_subnet_name
      nsg_name = "nsg-app001-workload-01"
    }

    workload_02 = {
      name     = var.workload_02_subnet_name
      nsg_name = "nsg-app001-workload-02"
    }

    management = {
      name     = var.management_subnet_name
      nsg_name = "nsg-app001-management"
    }
  }

  app001_internal_address_prefixes = var.virtual_network_address_space
}