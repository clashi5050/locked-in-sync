# ---- OIDC / auth (injected by the workflow as TF_VAR_*) ----
variable "arm_client_id" {
  type        = string
  description = "Azure AD app (client) ID used for OIDC login."
}

variable "arm_subscription_id" {
  type        = string
  description = "Target Azure subscription ID."
}

variable "arm_tenant_id" {
  type        = string
  description = "Azure AD tenant ID."
}

# ---- naming / placement ----
variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment slug (dev, test, prod). Feeds resource names."
}

variable "short_loc" {
  type        = string
  default     = "use2"
  description = "Short region tag used in names (e.g. use2 for East US 2)."
}

variable "location" {
  type        = string
  default     = "eastus2"
  description = "Azure region for the RG, storage, plan and function app."
}

variable "swa_location" {
  type        = string
  default     = "eastus2"
  description = "Static Web Apps is only offered in a few regions (eastus2, centralus, westus2, eastasia, westeurope)."
}

variable "app" {
  type        = string
  default     = "lockin"
  description = "Application short name used as a name prefix."
}

# ---- secrets ----
variable "app_shared_secret" {
  type        = string
  sensitive   = true
  description = "Shared secret the dashboard sends in the x-app-secret header. Provide via TF_VAR_app_shared_secret / a GitHub secret. NEVER commit it."
}
