#!/bin/bash

# Simple app deployment script for Windows Git Bash

TIMESTAMP="20251103133251"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"
WEB_APP_EAST="webapp-crud-east-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"

echo "Deploying application using az webapp up..."

# Deploy to East US
echo "Deploying to East US web app..."
az webapp up \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --runtime "PYTHON|3.11" \
    --location "eastus"

# Deploy to Central US  
echo "Deploying to Central US web app..."
az webapp up \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --runtime "PYTHON|3.11" \
    --location "centralus"

echo ""
echo "🎉 Application deployment completed!"
echo ""
echo "🌐 Your Application URLs:"
echo "========================"
echo "East US: https://${WEB_APP_EAST}.azurewebsites.net"
echo "Central US: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo "Traffic Manager: https://tm-crud-${TIMESTAMP}.trafficmanager.net"
echo ""
echo "⚠️  Important: Apps may take 5-10 minutes to fully start"
echo ""
echo "🧪 Test your deployment:"
echo "======================="
echo "1. Visit the URLs above"
echo "2. Try adding, editing, and deleting items"
echo "3. Check health: /health endpoint"