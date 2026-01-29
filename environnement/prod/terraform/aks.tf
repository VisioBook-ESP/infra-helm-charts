resource "azurerm_resource_group" "rg" {
  name     = "rg-aks"
  location = "australiacentral"
}
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-basic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-basic"

  default_node_pool {
    name                         = "system"
    vm_size                      = "Standard_D4s_v3"
    node_count                   = 1
    os_disk_size_gb              = 50
    max_pods                     = 30
    temporary_name_for_rotation  = "tempnp"
  }

  identity {
    type = "SystemAssigned"
  }
}
