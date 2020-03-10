# create public IP configuration for VMs
/* resource "azurerm_public_ip" "spoke1VmPublicIP" {
    name                         = "spoke1VmPublicIP"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

resource "azurerm_public_ip" "spoke2VmPublicIP" {
    name                         = "spoke2VmPublicIP"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
} */

resource "azurerm_public_ip" "hubVmPublicIP" {
    name                         = "hubVmPublicIP"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

# create Network Security Group to allow SSH to VMs
resource "azurerm_network_security_group" "nsg" {
    name                = "HubSpokeDemoNSG"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Ping"
        priority                   = 3000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Icmp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "VirtualNetwork"
    }

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

resource "azurerm_network_interface" "hubVmNIC" {
    name                        = "hubVmNIC"
    location                    = azurerm_resource_group.rg.location
    resource_group_name         = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "hubVmNICConfiguration"
        subnet_id                     = azurerm_subnet.hub-vnet-subnet1.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.hubVmPublicIP.id
    }

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

resource "azurerm_network_interface" "spoke1VmNIC" {
    name                        = "spoke1VmNIC"
    location                    = azurerm_resource_group.rg.location
    resource_group_name         = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "spoke1VmNICConfiguration"
        subnet_id                     = azurerm_subnet.spoke1-vnet-subnet1.id
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.spoke1VmPublicIP.id
    }

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

resource "azurerm_network_interface" "spoke2VmNIC" {
    name                        = "spoke2VmNIC"
    location                    = azurerm_resource_group.rg.location
    resource_group_name         = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "spoke2VmNICConfiguration"
        subnet_id                     = azurerm_subnet.spoke2-vnet-subnet1.id
        private_ip_address_allocation = "Dynamic"
        #public_ip_address_id          = azurerm_public_ip.spoke2VmPublicIP.id
    }

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

# associate network security group with network interfaces
resource "azurerm_network_interface_security_group_association" "spoke1VmNIC_NSG" {
    network_interface_id      = azurerm_network_interface.spoke1VmNIC.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "spoke2VmNIC_NSG" {
    network_interface_id      = azurerm_network_interface.spoke2VmNIC.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}