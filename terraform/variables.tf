# Azure Configuration Variables
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = null  # Will use ARM_SUBSCRIPTION_ID env var if not provided
}

# Resource Group Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

# Network Variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnet" {
  description = "Map of subnets to create"
  type = map(object({
    address_space = list(string)
  }))
}

# Container Apps Configuration
variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
}

variable "container_app_environment_name" {
  description = "Name of the Container App Environment"
  type        = string
}

variable "container_apps" {
  description = "Configuration for container applications"
  type = map(object({
    image            = string
    cpu              = number
    memory           = string
    target_port      = number
    external_enabled = bool
    min_replicas     = number
    max_replicas     = number
    env_vars = map(string)
  }))
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

# Database Variables
variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "sql_admin_username" {
  description = "Administrator username for SQL Server"
  type        = string
}

variable "sql_admin_password" {
  description = "Administrator password for SQL Server"
  type        = string
  sensitive   = true
}