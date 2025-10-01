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

# Container Apps using AVM module with for_each
module "container_apps" {
  source  = "Azure/avm-res-app-containerapp/azurerm"
  version = "~> 0.7.0"
  
  for_each = var.container_apps

  name                                  = "${each.key}-app"
  resource_group_name                   = module.resource_group.resource_group.name
  container_app_environment_resource_id = azurerm_container_app_environment.main.id
  revision_mode                         = "Single"
  tags                                  = var.tags

  template = {
    min_replicas = each.value.min_replicas
    max_replicas = each.value.max_replicas
    
    containers = [
      {
        name   = each.key
        image  = each.value.image
        cpu    = each.value.cpu
        memory = each.value.memory
        env = [
          for env_key, env_value in each.value.env_vars : {
            name  = env_key
            value = env_value
          }
        ]
      }
    ]
  }

  ingress = {
    allow_insecure_connections = false
    external_enabled          = each.value.external_enabled
    target_port              = each.value.target_port
    traffic_weight = [
      {
        percentage      = 100
        latest_revision = true
      }
    ]
  }
}

# Azure SQL Server with Database using AVM module
module "sql_server" {
  source  = "Azure/avm-res-sql-server/azurerm"
  version = "~> 0.1.0"  # Use compatible version

  name                = var.sql_server_name
  resource_group_name = module.resource_group.resource_group.name
  location            = var.location
  
  # SQL Server Configuration
  server_version                = "12.0"
  administrator_login           = var.sql_admin_username
  administrator_login_password  = var.sql_admin_password
  public_network_access_enabled = false  # Disable public access for security
  
  # Private Endpoint Configuration
  private_endpoints = {
    primary = {
      name                          = "${var.sql_server_name}-private-endpoint"
      subnet_resource_id            = module.subnets["db_subnet"].subnet.id
      subresource_names             = ["sqlServer"]
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.sql.id]
    }
  }

  # Database Configuration using submodule
  databases = {
    ecommerce = {
      name         = var.sql_database_name
      collation    = "SQL_Latin1_General_CP1_CI_AS"
      license_type = "LicenseIncluded"
      max_size_gb  = 20
      sku_name     = "Basic"
    }
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

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "${var.acr_name}${random_string.suffix.result}"
  resource_group_name = module.resource_group.resource_group.name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = true  # Enable for GitHub Actions access
  
  tags = var.tags
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
