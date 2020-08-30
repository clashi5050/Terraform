# Azure Provider
provider "azurerm" {
  version = "=2.0.0"
  features {}
}

# State Backend
terraform {
  backend "azurerm" {
    resource_group_name   = "Terraform-Resources"
    storage_account_name  = "labstorage21"
    container_name        = "terraform-state"
    key                   = "test.terraform.tfstate"
  }
}
