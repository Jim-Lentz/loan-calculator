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


##### testing checkov

resource "azurerm_virtual_network" "vnet" {
  name                = "neubank-vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = "${var.environment}-${var.resource_group_name}"

  tags = {
    Environment = var.environment
    Owner = "first.last@company.com"
    Project = "Mortgage Calculator"
  }
}

#Create subnets
resource "azurerm_subnet" "front-end-subnet" {
  name                 = "font-end-subnet"
  resource_group_name  = "${var.environment}-${var.resource_group_name}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/26"]
  service_endpoints = ["Microsoft.Web"]
/*
  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action","Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  } */

  lifecycle {
    ignore_changes = [
      delegation,
    ]
  }
}

#Create subnets
resource "azurerm_subnet" "back-end-subnet" {
  name                 = "back-end-subnet"
  resource_group_name  = "${var.environment}-${var.resource_group_name}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.64/26"]
  service_endpoints = ["Microsoft.Sql"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action","Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_network_security_group" "backend_nsg" {
  name                = "backend-nsg"
  location            = var.location
  resource_group_name = "${var.environment}-${var.resource_group_name}"

  tags = {
    Environment = var.environment
    Owner = "first.last@company.com"
    Project = "Mortgage Calculator"
  }
}

# Allow SQL traffic from the frontend subnet
resource "azurerm_network_security_rule" "allow_sql" {
  name                        = "allow-sql"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = azurerm_subnet.front-end-subnet.address_prefixes[0]
  destination_address_prefix  = "*"
  resource_group_name         = "${var.environment}-${var.resource_group_name}"
  network_security_group_name = azurerm_network_security_group.backend_nsg.name
}

# Allow API traffic from the frontend subnet
resource "azurerm_network_security_rule" "allow_api" {
  name                        = "allow-api"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22" #"8080"
  source_address_prefix       = "*" #azurerm_subnet.front-end-subnet.address_prefixes[0]
  destination_address_prefix  = "*"
  resource_group_name         = "${var.environment}-${var.resource_group_name}"
  network_security_group_name = azurerm_network_security_group.backend_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = azurerm_subnet.back-end-subnet
  network_security_group_id = azurerm_network_security_group.backend_nsg.id
}