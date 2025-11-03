#!/bin/bash

# Simplified Azure CRUD Application Deployment Script
# This version uses environment variables instead of Key Vault for easier deployment

set -e

# Configuration
TIMESTAMP=$(date +%Y%m%d%H%M%S)
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"
LOCATION_EAST="eastus"
LOCATION_CENTRAL="centralus"
LOCATION_WEST="westus"

# App Service Plans
APP_SERVICE_PLAN_EAST="asp-crud-east-${TIMESTAMP}"
APP_SERVICE_PLAN_CENTRAL="asp-crud-central-${TIMESTAMP}"

# Web Apps
WEB_APP_EAST="webapp-crud-east-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"

# Database
SQL_SERVER="sqlserver${TIMESTAMP}"
SQL_DATABASE="myDatabase"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="P@ssw0rd123!"

# Traffic Manager
TRAFFIC_MANAGER="tm-crud-${TIMESTAMP}"

echo "Starting Simplified Azure CRUD Application deployment..."
echo "Timestamp: ${TIMESTAMP}"
echo "Resource Group: ${RESOURCE_GROUP}"

# Login check
echo "Checking Azure login..."
az account show > /dev/null 2>&1 || { echo "Please run 'az login' first"; exit 1; }

# Create Resource Group
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION_EAST

# Create SQL Server and Database
echo "Creating SQL Server and Database..."
az sql server create \
    --name $SQL_SERVER \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION_WEST \
    --admin-user $SQL_ADMIN \
    --admin-password $SQL_PASSWORD

# Configure SQL Server firewall
echo "Configuring SQL Server firewall..."
az sql server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER \
    --name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

# Create SQL Database
az sql db create \
    --resource-group $RESOURCE_GROUP \
    --server $SQL_SERVER \
    --name $SQL_DATABASE \
    --service-objective S0

# Create App Service Plans
echo "Creating App Service Plans..."
az appservice plan create \
    --name $APP_SERVICE_PLAN_EAST \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION_EAST \
    --sku S1 \
    --is-linux

az appservice plan create \
    --name $APP_SERVICE_PLAN_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION_CENTRAL \
    --sku S1 \
    --is-linux

# Create Web Apps
echo "Creating Web Apps..."
az webapp create \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --plan $APP_SERVICE_PLAN_EAST \
    --runtime "PYTHON|3.11"

az webapp create \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --plan $APP_SERVICE_PLAN_CENTRAL \
    --runtime "PYTHON|3.11"

# Configure app settings with connection string
echo "Configuring app settings..."
CONNECTION_STRING="Driver={ODBC Driver 18 for SQL Server};Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=${SQL_DATABASE};Uid=${SQL_ADMIN};Pwd=${SQL_PASSWORD};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"

az webapp config appsettings set \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --settings SQL_CONNECTION_STRING="$CONNECTION_STRING"

az webapp config appsettings set \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --settings SQL_CONNECTION_STRING="$CONNECTION_STRING"

# Create Traffic Manager Profile
echo "Creating Traffic Manager..."
az network traffic-manager profile create \
    --name $TRAFFIC_MANAGER \
    --resource-group $RESOURCE_GROUP \
    --routing-method Performance \
    --unique-dns-name $TRAFFIC_MANAGER

# Add endpoints to Traffic Manager
az network traffic-manager endpoint create \
    --name "east-endpoint" \
    --profile-name $TRAFFIC_MANAGER \
    --resource-group $RESOURCE_GROUP \
    --type azureEndpoints \
    --target-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Web/sites/${WEB_APP_EAST}" \
    --endpoint-status Enabled

az network traffic-manager endpoint create \
    --name "central-endpoint" \
    --profile-name $TRAFFIC_MANAGER \
    --resource-group $RESOURCE_GROUP \
    --type azureEndpoints \
    --target-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Web/sites/${WEB_APP_CENTRAL}" \
    --endpoint-status Enabled

# Deploy application code
echo "Deploying application code..."

# Create deployment package
zip -r app.zip . -x "*.git*" "*.DS_Store*" "deploy*.sh" "README.md"

# Deploy to both web apps
az webapp deployment source config-zip \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --src app.zip

az webapp deployment source config-zip \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --src app.zip

# Clean up
rm app.zip

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Deployment Summary:"
echo "====================="
echo "Resource Group: $RESOURCE_GROUP"
echo "SQL Server: ${SQL_SERVER}.database.windows.net"
echo "Database: $SQL_DATABASE"
echo ""
echo "🌐 Application URLs:"
echo "==================="
echo "East US Web App: https://${WEB_APP_EAST}.azurewebsites.net"
echo "Central US Web App: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo "Traffic Manager: https://${TRAFFIC_MANAGER}.trafficmanager.net"
echo ""
echo "🔧 Management URLs:"
echo "=================="
echo "Azure Portal: https://portal.azure.com"
echo "Resource Group: https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/${RESOURCE_GROUP}/overview"
echo ""
echo "⚠️  Important Notes:"
echo "==================="
echo "1. It may take 5-10 minutes for the applications to fully start"
echo "2. The database will be initialized automatically on first access"
echo "3. Traffic Manager DNS propagation may take up to 5 minutes"
echo "4. Connection string is stored as environment variable (not Key Vault)"
echo ""
echo "🧪 Test your deployment:"
echo "======================="
echo "1. Visit the Traffic Manager URL to test load balancing"
echo "2. Try adding, editing, and deleting items"
echo "3. Check the health endpoint: /health"
echo ""
echo "💰 Cost Optimization:"
echo "===================="
echo "Remember to delete resources when done testing:"
echo "az group delete --name $RESOURCE_GROUP --yes --no-wait"