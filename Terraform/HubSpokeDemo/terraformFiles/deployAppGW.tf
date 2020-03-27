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