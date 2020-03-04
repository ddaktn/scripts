provider "azurerm" {
  version = 1.38
}

terraform {
    backend "azurerm" {
        #subscription_id      = "2d71e24b-ab7e-4423-b3ab-1a7ae8c134ce"
        resource_group_name  = "Terraform_rg"
        storage_account_name = "fntslabstorage4terraform"
        container_name       = "statefile"
        key                  = "terraform.tfstate"
    }
}
