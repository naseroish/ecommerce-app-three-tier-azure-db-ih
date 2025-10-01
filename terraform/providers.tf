terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  # If var.subscription_id is null, it will automatically use ARM_SUBSCRIPTION_ID environment variable
}

