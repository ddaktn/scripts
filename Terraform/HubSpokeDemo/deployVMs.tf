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