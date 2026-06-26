terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.40"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }

  # Intentionally local state: this creates the storage account that the rest
  # of the project's remote state lives in, so it can't depend on it.
}

provider "azurerm" {
  features {}
}
