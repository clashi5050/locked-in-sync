output "resource_group" {
  value = azurerm_resource_group.this.name
}

output "function_app_name" {
  value = azurerm_linux_function_app.this.name
}

output "function_base_url" {
  description = "Paste this into the dashboard's Cloud Sync panel."
  value       = "https://${azurerm_linux_function_app.this.default_hostname}"
}

output "static_web_app_name" {
  value = azurerm_static_web_app.this.name
}

output "static_web_app_url" {
  description = "Your live dashboard URL."
  value       = "https://${azurerm_static_web_app.this.default_host_name}"
}
