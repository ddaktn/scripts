provider "azurerm" {
    version = 2.0
    features {}
}

terraform {
    backend "azurerm" {
        resource_group_name  = "Terraform_rg"
        storage_account_name = "fntslabstorage4terraform"
        container_name       = "statefile"
        key                  = "terraform.tfstate"
    }
}
