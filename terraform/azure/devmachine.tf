terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "dev" {
  name     = "dev-machine-resources"
  location = "West US 2"
}

resource "azurerm_virtual_network" "dev" {
  name                = "dev-machine-network"
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location
  address_space       = ["10.101.0.0/16"]
}

resource "azurerm_subnet" "dev" {
  name                 = "dev-machine-subnet"
  resource_group_name  = azurerm_resource_group.dev.name
  virtual_network_name = azurerm_virtual_network.dev.name
  address_prefixes     = ["10.101.0.0/24"]
}

resource "azurerm_public_ip" "dev" {
  name                = "dev-machine-public-ip"
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "dev" {
  name                = "dev-machine-network-interface"
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev.id
  }
}
