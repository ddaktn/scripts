# create virtual networks with subnets
resource "azurerm_virtual_network" "hub-vnet" {
    resource_group_name = azurerm_resource_group.rg.name
    name                = "Hub-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

resource "azurerm_subnet" "hub-vnet-subnet1" {
    name                 = "Subnet-1"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefix       = "10.0.1.0/24"
}

resource "azurerm_virtual_network" "spoke1-vnet" {
    resource_group_name = azurerm_resource_group.rg.name
    name                = "Spoke1-vnet"
    address_space       = ["10.1.0.0/16"]
    location            = azurerm_resource_group.rg.location

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

resource "azurerm_subnet" "spoke1-vnet-subnet1" {
    name                 = "Subnet-1"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.spoke1-vnet.name
    address_prefix       = "10.1.0.0/24"
}

resource "azurerm_virtual_network" "spoke2-vnet" {
    resource_group_name = azurerm_resource_group.rg.name
    name                = "spoke2-vnet"
    address_space       = ["10.2.0.0/16"]
    location            = azurerm_resource_group.rg.location

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

resource "azurerm_subnet" "spoke2-vnet-subnet1" {
    name                 = "Subnet-1"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.spoke2-vnet.name
    address_prefix       = "10.2.0.0/24"
}