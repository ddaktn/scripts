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