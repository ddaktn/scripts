# create route table with User Defined Routes for both spoke vnets
resource "azurerm_route_table" "spoke1_udr" {
  name                          = "Spoke1_UDR"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = true

  route {
    name                   = "UDR-Spoke1"
    address_prefix         = "10.1.0.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "spoke1_udr_assoc" {
  subnet_id      = azurerm_subnet.spoke1-vnet-subnet1.id
  route_table_id = azurerm_route_table.spoke1_udr.id
}

resource "azurerm_route_table" "spoke2_udr" {
  name                          = "Spoke2_UDR"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = true

  route {
    name                   = "UDR-Spoke2"
    address_prefix         = "10.2.0.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "spoke2_udr_assoc" {
  subnet_id      = azurerm_subnet.spoke2-vnet-subnet1.id
  route_table_id = azurerm_route_table.spoke2_udr.id
}