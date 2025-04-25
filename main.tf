terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.27.0"
    }
    cloudinit = {
        source = "hashicorp/cloudinit"
        version = "2.3.6"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "cloudinit" {
  # Configuration options
}