# declare privider
provider "azurerm" {
    version = 2.0
    features {}
}

# create virtual networks with subnets
resource "azurerm_resource_group" "rg" {
    name     = "HubSpokeDemo_rg"
    location = "centralus"

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

resource "azurerm_virtual_network" "hub-vnet" {
    resource_group_name = "HubSpokeDemo_rg"
    name                = "Hub-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "centralus"

    subnet {
        name            = "subnet1"
        address_prefix  = "10.0.0.0/24"
    }
}

resource "azurerm_virtual_network" "spoke1-vnet" {
    resource_group_name = "HubSpokeDemo_rg"
    name                = "Spoke1-vnet"
    address_space       = ["10.1.0.0/16"]
    location            = "centralus"

    subnet {
        name            = "subnet1"
        address_prefix  = "10.1.0.0/24"
    }
}

resource "azurerm_virtual_network" "spoke2-vnet" {
    resource_group_name = "HubSpokeDemo_rg"
    name                = "spoke2-vnet"
    address_space       = ["10.2.0.0/16"]
    location            = "centralus"

    subnet {
        name            = "subnet1"
        address_prefix  = "10.2.0.0/24"
    }
}

# create virtual network peerings
resource "azurerm_virtual_network_peering" "hub-spoke1" {
    name                      = "HubToSpoke1"
    resource_group_name       = "HubSpokeDemo_rg"
    virtual_network_name      = "Hub-vnet"
    remote_virtual_network_id = azurerm_virtual_network.spoke1-vnet.id  
    allow_forwarded_traffic   = true
    allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "hub-spoke2" {
    name                      = "HubToSpoke2"
    resource_group_name       = "HubSpokeDemo_rg"
    virtual_network_name      = "Hub-vnet"
    remote_virtual_network_id = azurerm_virtual_network.spoke2-vnet.id 
    allow_forwarded_traffic   = true
    allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "spoke1-hub" {
    name                      = "Spoke1ToHub"
    resource_group_name       = "HubSpokeDemo_rg"
    virtual_network_name      = "Spoke1-vnet"
    remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id 
    #use_remote_gateways       = true
}

resource "azurerm_virtual_network_peering" "spoke2-hub" {
    name                      = "Spoke2ToHub"
    resource_group_name       = "HubSpokeDemo_rg"
    virtual_network_name      = "Spoke2-vnet"
    remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id 
    #use_remote_gateways       = true
}

# create virtual machines to test connectivity
