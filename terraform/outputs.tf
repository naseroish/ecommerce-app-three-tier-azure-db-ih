# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.resource_group.name
}

# Network Outputs
output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.vnet.virtual_network.name
}

output "app_subnet_id" {
  description = "ID of the app subnet"
  value       = module.subnets["app_subnet"].subnet.id
}

output "db_subnet_id" {
  description = "ID of the database subnet"
  value       = module.subnets["db_subnet"].subnet.id
}

# Container Apps Outputs
output "container_app_environment_id" {
  description = "ID of the Container App Environment"
  value       = azurerm_container_app_environment.main.id
}

output "container_app_environment_default_domain" {
  description = "Default domain of the Container App Environment"
  value       = azurerm_container_app_environment.main.default_domain
}

output "frontend_app_url" {
  description = "URL of the frontend application"
  value       = try(azurerm_container_app.main["frontend"].latest_revision_fqdn, azurerm_container_app.main["frontend"].ingress[0].fqdn, "Not available")
}

output "backend_app_internal_url" {
  description = "Internal URL of the backend application"  
  value       = try(azurerm_container_app.main["backend"].latest_revision_fqdn, azurerm_container_app.main["backend"].ingress[0].fqdn, "Not available")
}

output "container_apps_info" {
  description = "Information about all container apps"
  value = {
    for app_name, app_config in var.container_apps : app_name => {
      name         = azurerm_container_app.main[app_name].name
      resource_id  = azurerm_container_app.main[app_name].id
    }
  }
}

# Environment variables for cross-app communication (internal)
output "app_communication_info" {
  description = "Internal communication information between apps"
  value = {
    frontend = {
      internal_hostname = "frontend-app:3000"
      api_endpoint      = "http://backend-app:3001/api"
    }
    backend = {
      internal_hostname = "backend-app:3001"
      cors_origin      = "http://frontend-app:3000"
    }
  }
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

# Database Outputs
output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_server_private_fqdn" {
  description = "Private FQDN of the SQL Server (via private endpoint)"
  value       = "${var.sql_server_name}.privatelink.database.windows.net"
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.main.name
}

output "sql_server_resource_id" {
  description = "Resource ID of the SQL Server"
  value       = azurerm_mssql_server.main.id
}

# Container Registry Outputs
output "acr_login_server" {
  description = "Login server URL for the Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "acr_name" {
  description = "Name of the Container Registry"
  value       = azurerm_container_registry.main.name
}

output "acr_admin_username" {
  description = "Admin username for Container Registry"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = false
}

output "acr_admin_password" {
  description = "Admin password for Container Registry"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

# Storage Account Outputs
output "storage_account_name" {
  description = "Name of the Storage Account for Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "storage_container_name" {
  description = "Name of the Storage Container for Terraform state"
  value       = azurerm_storage_container.tfstate.name
}