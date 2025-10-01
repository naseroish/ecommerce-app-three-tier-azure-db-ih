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
  # subscription_id will use ARM_SUBSCRIPTION_ID environment variable or TF_VAR_subscription_id
}

