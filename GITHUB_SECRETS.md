# GitHub Secrets Setup

This document outlines the required GitHub secrets for the CI/CD pipeline.

## Required Secrets

### Azure Authentication
```
AZURE_CREDENTIALS = {
  "clientId": "your-service-principal-client-id",
  "clientSecret": "your-service-principal-client-secret", 
  "subscriptionId": "your-azure-subscription-id",
  "tenantId": "your-azure-tenant-id"
}
```

### Azure Service Principal Components (Alternative to AZURE_CREDENTIALS)
```
AZURE_CLIENT_ID = "your-service-principal-client-id"
AZURE_CLIENT_SECRET = "your-service-principal-client-secret"
AZURE_SUBSCRIPTION_ID = "80646857-9142-494b-90c5-32fea6acbc41"  # Your subscription ID
AZURE_TENANT_ID = "your-azure-tenant-id"
```

### Database Configuration
```
SQL_ADMIN_PASSWORD = "P@ssw0rd123!"
SQL_SERVER_NAME = "ecommerce-sql-server"
DB_NAME = "ecommerce-db"
DB_USER = "sqladmin"
DB_PASSWORD = "P@ssw0rd123!"
```

### Application Secrets
```
JWT_SECRET = "your-super-secret-jwt-key-here-make-it-long-and-secure-12345"
```

## How to Set Up Secrets

1. Go to your GitHub repository
2. Click on **Settings** tab
3. Navigate to **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add each secret with the exact name and value

## Service Principal Creation

Run these Azure CLI commands to create a service principal:

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "ecommerce-app-sp" \
  --role Contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
  --sdk-auth

# Output will be the AZURE_CREDENTIALS JSON
```

## Testing Secrets

The workflow will validate secrets during the infrastructure deployment phase.