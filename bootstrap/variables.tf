variable "resource_group_name" {
  type        = string
  default     = "rg-tfstate"
  description = "Resource group that holds the Terraform state storage account."
}

variable "location" {
  type        = string
  default     = "eastus2"
  description = "Azure region for the state storage account."
}

variable "container_name" {
  type        = string
  default     = "tfstate"
  description = "Blob container that holds .tfstate files."
}
