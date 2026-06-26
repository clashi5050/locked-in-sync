locals {
  suffix    = "${var.app}-${var.environment}-${var.short_loc}"
  rg_name   = "rg-${local.suffix}"
  # storage account names: 3-24 chars, lowercase letters + digits only
  sa_name   = lower(replace("st${var.app}${var.environment}${var.short_loc}", "-", ""))
  plan_name = "plan-${local.suffix}"
  func_name = "func-${local.suffix}-${random_string.rand.result}"
  swa_name  = "swa-${local.suffix}"

  tags = {
    app         = var.app
    environment = var.environment
    managed_by  = "terraform"
    purpose     = "personal-lockin-dashboard"
  }
}

# Random suffix so the globally-unique function app hostname doesn't collide.
resource "random_string" "rand" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# One storage account serves double duty: the Functions runtime AND the data Table.
resource "azurerm_storage_account" "this" {
  name                     = local.sa_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.tags
}

# The dashboard's entire state lives as a single row in this table.
resource "azurerm_storage_table" "state" {
  name                 = "lockinstate"
  storage_account_name = azurerm_storage_account.this.name
}

# Consumption plan (Y1): 1M free executions/month, then pay-per-use. Effectively $0 here.
resource "azurerm_service_plan" "this" {
  name                = local.plan_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.tags
}

resource "azurerm_linux_function_app" "this" {
  name                       = local.func_name
  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  service_plan_id            = azurerm_service_plan.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key

  site_config {
    application_stack {
      node_version = "20"
    }

    # Only the deployed dashboard (and localhost during dev) may call the API from a browser.
    cors {
      allowed_origins     = [
        "https://${azurerm_static_web_app.this.default_host_name}",
        "http://localhost:3000",
        "http://127.0.0.1:5500"
      ]
      support_credentials = false
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "node"
    # The functions read/write the Table using this connection string.
    DATA_CONN                = azurerm_storage_account.this.primary_connection_string
    DATA_TABLE               = azurerm_storage_table.state.name
    # Guards every request via the x-app-secret header.
    APP_SHARED_SECRET        = var.app_shared_secret
  }

  tags = local.tags
}

# Free-tier Static Web App hosts the single-file dashboard (index.html).
resource "azurerm_static_web_app" "this" {
  name                = local.swa_name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.swa_location
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = local.tags
}
