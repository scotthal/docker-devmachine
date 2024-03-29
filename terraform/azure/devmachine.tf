terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.48.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "cloudinit" {}

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

resource "azurerm_network_security_group" "dev" {
  name                = "dev-machine-network-security-group"
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location
  security_rule {
    name                       = "dev-machine-security-rule-tcp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_ranges    = ["22", "80", "443", "8000-8999"]
  }
}

resource "azurerm_network_interface_security_group_association" "dev" {
  network_interface_id      = azurerm_network_interface.dev.id
  network_security_group_id = azurerm_network_security_group.dev.id
}

data "cloudinit_config" "dev" {
  part {
    content_type = "text/x-shellscript"
    filename     = "setup.sh"
    content      = file("${path.module}/../../setup.sh")
  }
}

resource "azurerm_linux_virtual_machine" "dev" {
  name                  = "dev"
  resource_group_name   = azurerm_resource_group.dev.name
  location              = azurerm_resource_group.dev.location
  size                  = "Standard_D2as_v4"
  priority              = "Spot"
  max_bid_price         = 0.05
  eviction_policy       = "Deallocate"
  network_interface_ids = [azurerm_network_interface.dev.id]
  os_disk {
    name                 = "dev-machine-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-lunar"
    sku       = "23_04-gen2"
    version   = "latest"
  }
  custom_data    = data.cloudinit_config.dev.rendered
  admin_username = "scotthal"
  admin_ssh_key {
    username   = "scotthal"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

data "azurerm_public_ip" "dev" {
  name                = azurerm_public_ip.dev.name
  resource_group_name = azurerm_resource_group.dev.name
}

output "instance_public_ip_address" {
  description = "The public IP address of the instance"
  value       = data.azurerm_public_ip.dev.ip_address
}
