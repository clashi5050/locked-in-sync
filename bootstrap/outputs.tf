output "tfstate_resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "tfstate_storage_account_name" {
  description = "Put this value in the TFSTATE_SA GitHub repo/environment variable."
  value       = azurerm_storage_account.tfstate.name
}

output "tfstate_container_name" {
  value = azurerm_storage_container.tfstate.name
}
