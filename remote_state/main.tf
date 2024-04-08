terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.97.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate"
  location = "East US"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${random_string.resource_code.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
#  public_network_access_enabled = false
  allow_nested_items_to_be_public = false
 # shared_access_key_enabled = false
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
  sas_policy {
    expiration_period = "90.00:00:00"
    expiration_action = "Log"
  }


    tags = {
    Owner = "first.last@company.com"
    Project = "Mortgage Calculator"
  }
}
/*
resource "azurerm_private_endpoint" "tfendpoint" {
  name                 = "tf_private_endpoint"
  location             = azurerm_resource_group.tfstate.location
  resource_group_name  = azurerm_resource_group.tfstate.name
  subnet_id            = azurerm_subnet.example.id

  private_service_connection {
    name                           = "tf_psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.tfstate.id
    subresource_names              = ["blob"]
  }
}
*/

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}