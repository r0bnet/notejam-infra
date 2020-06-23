resource "azurerm_resource_group" "aks_rg" {
  count    = length(local.locations)
  name     = "${var.prefix}-aks${count.index + 1}-rg"
  location = element(local.locations, count.index)
}

resource "azurerm_kubernetes_cluster" "aks" {
  count               = length(local.locations)
  name                = "${var.prefix}-aks${count.index + 1}"
  location            = element(local.locations, count.index)
  resource_group_name = element(azurerm_resource_group.aks_rg.*, count.index).name
  dns_prefix          = "notejamaks${count.index + 1}"

  kubernetes_version  = "1.16.9"
  node_resource_group = "${var.prefix}-aks${count.index + 1}-nodes-rg"

  default_node_pool {
    name                 = "default"
    type                 = "VirtualMachineScaleSets"
    enable_auto_scaling  = true
    vm_size              = "Standard_D2_v2"
    orchestrator_version = "1.16.9"
    min_count            = 2
    node_count           = 2
    max_count            = 5
    availability_zones   = [1, 2, 3]
    vnet_subnet_id       = element(azurerm_subnet.k8s.*, count.index).id
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "Standard"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [default_node_pool.0.node_count]
  }
}
