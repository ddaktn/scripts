# create subnet for Azure Firewall
resource "azurerm_subnet" "AzureFirewallSubnet" {
    name                 = "AzureFirewallSubnet"
    ### Bug in Terraform; Azure Firewall Subnet MUST be named "AzureFirewallSubnet" ###
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefix       = "10.0.1.0/24"
}

# create public IP for AZ Firewall
resource "azurerm_public_ip" "pip-fw" {
    name                = "PIP-fw"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
}

# create AZ Firewall
resource "azurerm_firewall" "fw" {
    name                = "testfirewall"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                 = "configuration"
        subnet_id            = azurerm_subnet.AzureFirewallSubnet.id
        public_ip_address_id = azurerm_public_ip.pip-fw.id
    }
}