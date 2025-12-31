resource "azurerm_resource_group" "rg" {
  name     = "rg-aks"
  location = "francecentral"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-basic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-basic"

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "standard_a2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
