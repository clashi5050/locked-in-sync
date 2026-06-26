terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.40"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstatelab"
    storage_account_name = "tfstatestoragelab2"
    container_name       = "tfstate"
    key                  = "homelab.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }
}

provider "azurerm" {
  subscription_id = var.arm_subscription_id
  client_id       = var.arm_client_id
  tenant_id       = var.arm_tenant_id

  use_oidc = true
  features {}
}
