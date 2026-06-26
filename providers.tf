terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.40"
    }
  }

  # resource_group_name / storage_account_name / container_name / key are supplied
  # at init time via `-backend-config=backend.hcl` (see backend.hcl.example).
  backend "azurerm" {
    use_azuread_auth = true
    use_oidc         = true
  }
}

provider "azurerm" {
  subscription_id = var.arm_subscription_id
  client_id       = var.arm_client_id
  tenant_id       = var.arm_tenant_id

  use_oidc = true
  features {}
}
