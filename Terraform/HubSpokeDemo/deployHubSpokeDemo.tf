# declare privider
provider "azurerm" {
    version = 2.0
    features {}
}

# create resource group
resource "azurerm_resource_group" "rg" {
    name     = "HubSpokeDemo_rg"
    location = "centralus"

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

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

# create virtual machines
resource "azurerm_virtual_machine" "hubVm" {
    name                             = "hubVm"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.hubVmNIC.id]
    vm_size                          = "Standard_A0"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "openLogic"
        offer     = "CentOS"
        sku       = "7-CI"
        version   = "latest"
    }

    storage_os_disk {
        name              = "hubVmdisk"
        managed_disk_type = "Standard_LRS"
        caching           = "ReadWrite"
        create_option     = "FromImage"
    }

    os_profile {
        computer_name  = "hubVm"
        admin_username = "fnts.admin"
        admin_password = "Password#12"
    } 

    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_virtual_machine" "spoke1Vm" {
    name                             = "spoke1Vm"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.spoke1VmNIC.id]
    vm_size                          = "Standard_A0"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "openLogic"
        offer     = "CentOS"
        sku       = "7-CI"
        version   = "latest"
    }

    storage_os_disk {
        name              = "spoke1Vmdisk"
        managed_disk_type = "Standard_LRS"
        caching           = "ReadWrite"
        create_option     = "FromImage"
    }

    os_profile {
        computer_name  = "spoke1Vm"
        admin_username = "fnts.admin"
        admin_password = "Password#12"
    } 

    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_virtual_machine" "spoke2Vm" {
    name                             = "spoke2Vm"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.spoke2VmNIC.id]
    vm_size                          = "Standard_A0"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "openLogic"
        offer     = "CentOS"
        sku       = "7-CI"
        version   = "latest"
    }

    storage_os_disk {
        name              = "spoke2Vmdisk"
        managed_disk_type = "Standard_LRS"
        caching           = "ReadWrite"
        create_option     = "FromImage"
    }

    os_profile {
        computer_name  = "spoke2Vm"
        admin_username = "fnts.admin"
        admin_password = "Password#12"
    } 

    os_profile_linux_config {
        disable_password_authentication = false
    }
}

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
    name                  = "spoke2spoke"
    source_addresses      = ["10.0.0.0/8"]
    destination_ports     = ["*"]
    destination_addresses = ["10.0.0.0/8"]
    protocols             = ["Any"]
  }
}

# create AZ Firewall application rule to allow outbound web traffic
resource "azurerm_firewall_application_rule_collection" "fw_app_rule" {
  name                = "Internet_Outbound_Allow"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 300
  action              = "Allow"

  rule {
    name             = "internet_out"
    source_addresses = ["10.0.0.0/8"]
    target_fqdns     = ["*"]
    protocol {
      port = "443"
      type = "Https"
    }
    protocol {
      port = "80"
      type = "Http"
    }
  }
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.hub-vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.hub-vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.hub-vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.hub-vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.hub-vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.hub-vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.hub-vnet.name}-rdrcfg"
}

resource "azurerm_subnet" "hub-vnet-app_gw" {
    name                 = "Subnet-AppGW"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hub-vnet.name
    address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "app_gw_PublicIP" {
    name                         = "AppGatewayPIP"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform"
        deployedby  = "Doug Nelson"
    }
}

resource "azurerm_application_gateway" "app_gw" {
  name                = "hub-spoke-appgateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.hub-vnet-app_gw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gw_PublicIP.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = ["10.1.0.4"]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}