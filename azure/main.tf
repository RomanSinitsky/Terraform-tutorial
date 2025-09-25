terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.45.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "terraform_azure_providers" {
  name     = "terraform_azure_providers"
  location = "East US"
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1s"
  description = "Size of the VM"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "admin_password" {
  type        = string
  description = "Admin password for the VM"
  sensitive   = true
}

resource "azurerm_virtual_network" "demo" {
  name                = "demo-vnet"
  resource_group_name = azurerm_resource_group.terraform_azure_providers.name
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "demo" {
  name                 = "demo-subnet"
  resource_group_name  = azurerm_virtual_network.demo.resource_group_name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.demo
  ]
}

module "avm-res-compute-virtualmachine" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.19.3"

  name                = var.vm_name
  resource_group_name = azurerm_resource_group.terraform_azure_providers.name
  location            = azurerm_resource_group.terraform_azure_providers.location
  zone                = "1"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interfaces = {
    network_interface_1 = {
      name    = "testnic1"
      primary = true
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "testnic1-ipconfig1"
          create_public_ip_address      = true
          private_ip_subnet_resource_id = azurerm_subnet.demo.id
          private_ip_address_allocation = "Dynamic"
          public_ip_address_name        = "demo-pip"
        }
      }
    }
  }

  os_type  = "Linux"
  sku_size = var.vm_size

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_resource_group.terraform_azure_providers,
    azurerm_virtual_network.demo,
    azurerm_subnet.demo,
  ]
}