module "resource_group" {
  source   = "./azurerm_resource_group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source              = "./azurerm_virtual_network"
  name                = var.vnet_name
  resource_group_name = module.resource_group.resource_group.name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

module "subnets" {
  source              = "./azurerm_subnets"
  for_each            = var.subnet
  name                = each.key
  resource_group_name = module.resource_group.resource_group.name
  vnet_name           = module.vnet.virtual_network.name
  address_prefixes    = each.value.address_space
}

# Log Analytics Workspace for Container App Environment
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = module.resource_group.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Container App Environment with VNet Integration
resource "azurerm_container_app_environment" "main" {
  name                           = var.container_app_environment_name
  location                       = var.location
  resource_group_name            = module.resource_group.resource_group.name
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.main.id
  infrastructure_subnet_id       = module.subnets["app_subnet"].subnet.id
  internal_load_balancer_enabled = false
  tags                           = var.tags
}

# Container Apps (direct azurerm resources)
resource "azurerm_container_app" "main" {
  for_each = var.container_apps
  
  name                         = "${each.key}-app"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = module.resource_group.resource_group.name
  revision_mode                = "Single"
  
  template {
    min_replicas = each.value.min_replicas
    max_replicas = each.value.max_replicas
    
    container {
      name   = each.key
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory
      
      dynamic "env" {
        for_each = each.value.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }
  
  ingress {
    allow_insecure_connections = false
    external_enabled          = each.value.external_enabled
    target_port              = each.value.target_port
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
  
  tags = var.tags
}

# Azure SQL Server (direct azurerm resource)
resource "azurerm_mssql_server" "main" {
  name                         = "${var.sql_server_name}-${random_string.suffix.result}"
  resource_group_name          = module.resource_group.resource_group.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  public_network_access_enabled = false
  
  tags = var.tags
}

# Azure SQL Database
resource "azurerm_mssql_database" "main" {
  name         = var.sql_database_name
  server_id    = azurerm_mssql_server.main.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2  # Basic tier supports up to 2GB
  sku_name     = "Basic"
  
  tags = var.tags
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "sql" {
  name                = "${var.sql_server_name}-${random_string.suffix.result}-private-endpoint"
  location            = var.location
  resource_group_name = module.resource_group.resource_group.name
  subnet_id           = module.subnets["db_subnet"].subnet.id

  private_service_connection {
    name                           = "${var.sql_server_name}-${random_string.suffix.result}-privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
  }

  tags = var.tags
}

# Private DNS Zone for SQL Server (still needed for the module)
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = module.resource_group.resource_group.name
  tags                = var.tags
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "sql-dns-link"
  resource_group_name   = module.resource_group.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = module.vnet.virtual_network.id
  registration_enabled  = false
  tags                  = var.tags
}

# Random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Storage Account for Terraform State (optional - for remote backend)
resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${random_string.suffix.result}"
  resource_group_name      = module.resource_group.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  blob_properties {
    versioning_enabled = true
  }
  
  tags = var.tags
}

# Storage Container for Terraform State
resource "azurerm_storage_container" "tfstate" {
  name                 = "tfstate"
  storage_account_id   = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
