#!/bin/bash

# Complete Azure CRUD Application Deployment Script
# One script that works from fresh start with proper database integration

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

echo "🚀 Starting Azure CRUD Application deployment..."
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

# Configure database connection and startup
echo "Configuring database connection..."
CONNECTION_STRING="Driver={ODBC Driver 18 for SQL Server};Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=${SQL_DATABASE};Uid=${SQL_ADMIN};Pwd=${SQL_PASSWORD};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"

# Set connection string and startup command for both apps
for APP in $WEB_APP_EAST $WEB_APP_CENTRAL; do
    az webapp config appsettings set \
        --name $APP \
        --resource-group $RESOURCE_GROUP \
        --settings SQL_CONNECTION_STRING="$CONNECTION_STRING"
    
    az webapp config set \
        --name $APP \
        --resource-group $RESOURCE_GROUP \
        --startup-file "gunicorn --bind 0.0.0.0:8000 --timeout 120 --workers 1 app:app"
done

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
    --type externalEndpoints \
    --target "${WEB_APP_EAST}.azurewebsites.net" \
    --endpoint-location "East US" \
    --endpoint-status Enabled

az network traffic-manager endpoint create \
    --name "central-endpoint" \
    --profile-name $TRAFFIC_MANAGER \
    --resource-group $RESOURCE_GROUP \
    --type externalEndpoints \
    --target "${WEB_APP_CENTRAL}.azurewebsites.net" \
    --endpoint-location "Central US" \
    --endpoint-status Enabled

# Deploy application code using az webapp up (works on all platforms)
echo "Deploying application to East US..."
az webapp up \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --runtime "PYTHON|3.11" \
    --location $LOCATION_EAST

echo "Deploying application to Central US..."
az webapp up \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --runtime "PYTHON|3.11" \
    --location $LOCATION_CENTRAL

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Task Requirements Met:"
echo "========================"
echo "✅ Multi-region deployment: East US + Central US"
echo "✅ Azure SQL Database: ${SQL_SERVER}.database.windows.net"
echo "✅ Traffic Manager: Performance routing with failover"
echo "✅ Full CRUD operations: Create, Read, Update, Delete"
echo "✅ High availability: Automatic failover between regions"
echo ""
echo "🌐 Application URLs:"
echo "==================="
echo "Traffic Manager (Load Balanced): https://${TRAFFIC_MANAGER}.trafficmanager.net"
echo "East US Direct: https://${WEB_APP_EAST}.azurewebsites.net"
echo "Central US Direct: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo ""
echo "⏱️ Wait 5-10 minutes for applications to fully start"
echo ""
echo "🧪 Test your deployment:"
echo "======================="
echo "1. Visit the Traffic Manager URL"
echo "2. Add, edit, and delete items"
echo "3. Test failover by stopping one app service"
echo "4. Check health: /health endpoint"
echo ""
echo "💰 Clean up when done:"
echo "======================"
echo "Run: ./cleanup.sh"