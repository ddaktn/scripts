# create subnet for Azure Firewall
resource "azurerm_subnet" "AzureFirewallSubnet" {
    name                 = "AzureFirewallSubnet"
    ### Bug in Terraform; Azure Firewall Subnet MUST be named "AzureFirewallSubnet" ###
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefix       = "10.0.0.0/24"
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

# create AZ Firewall network rule to allow traffic between spokes
resource "azurerm_firewall_network_rule_collection" "fw_network_rule" {
  name                = "testcollection"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "spoke2spoke"
    source_addresses = ["10.0.0.0/8"]
    destination_ports = ["*"]
    destination_addresses = ["10.0.0.0/8"]
    protocols = ["Any"]
  }
}