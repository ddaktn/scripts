# create virtual network peerings
resource "azurerm_virtual_network_peering" "hub-spoke1" {
    name                      = "HubToSpoke1"
    resource_group_name       = azurerm_resource_group.rg.name
    virtual_network_name      = azurerm_virtual_network.hub-vnet.name
    remote_virtual_network_id = azurerm_virtual_network.spoke1-vnet.id  
    allow_forwarded_traffic   = true
    allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "hub-spoke2" {
    name                      = "HubToSpoke2"
    resource_group_name       = azurerm_resource_group.rg.name
    virtual_network_name      = azurerm_virtual_network.hub-vnet.name
    remote_virtual_network_id = azurerm_virtual_network.spoke2-vnet.id 
    allow_forwarded_traffic   = true
    allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "spoke1-hub" {
    name                      = "Spoke1ToHub"
    resource_group_name       = azurerm_resource_group.rg.name
    virtual_network_name      = azurerm_virtual_network.spoke1-vnet.name
    remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id 
    allow_forwarded_traffic   = true
    #use_remote_gateways       = true
}

resource "azurerm_virtual_network_peering" "spoke2-hub" {
    name                      = "Spoke2ToHub"
    resource_group_name       = azurerm_resource_group.rg.name
    virtual_network_name      = azurerm_virtual_network.spoke2-vnet.name
    remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id 
    allow_forwarded_traffic   = true
    #use_remote_gateways       = true
}