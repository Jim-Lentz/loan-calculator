 terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

#Backend is set on the command line
    backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "tfstateyyrxc"
      container_name       = "tfstate"
#      key                  = "$dev-terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-${var.resource_group_name}"
  location = var.location

  tags = {
    Environment = var.environment
    Owner = "first.last@company.com"
    Project = "Mortgage Calculator-test merge"
  }
}
