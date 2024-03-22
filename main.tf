provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "dev-rgp-cis-neubank-use-001"
  location = "East US"

  tags = {
    Environment = "Dev"
    Owner = "first.last@company.com"
    Project = "Mortgage Calculator"
  }
}
