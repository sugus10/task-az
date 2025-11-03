#!/bin/bash

# Fix the current deployment by completing the Traffic Manager setup and deploying the app

set -e

# Use the same timestamp from the current deployment
TIMESTAMP="20251103133251"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"
WEB_APP_EAST="webapp-crud-east-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"
TRAFFIC_MANAGER="tm-crud-${TIMESTAMP}"

echo "Fixing deployment for Resource Group: ${RESOURCE_GROUP}"

# Add endpoints to Traffic Manager using external endpoints (simpler approach)
echo "Adding Traffic Manager endpoints..."
az network traffic-manager endpoint create \
    --name "east-endpoint" \
    --profile-name $TRAFFIC_MANAGER \
    --resource-group $RESOURCE_GROUP \
    --type externalEndpoints \
    --target "${WEB_APP_EAST}.azurewebsites.net" \
    --endpoint-status Enabled

az network traffic-manager endpoint create \
    --name "central-endpoint" \
    --profile-name $TRAFFIC_MANAGER \
    --resource-group $RESOURCE_GROUP \
    --type externalEndpoints \
    --target "${WEB_APP_CENTRAL}.azurewebsites.net" \
    --endpoint-status Enabled

# Deploy application code
echo "Deploying application code..."

# Create deployment package
zip -r app.zip . -x "*.git*" "*.DS_Store*" "deploy*.sh" "README.md" "fix-deployment.sh" "cleanup.sh"

# Deploy to both web apps
echo "Deploying to East US web app..."
az webapp deployment source config-zip \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --src app.zip

echo "Deploying to Central US web app..."
az webapp deployment source config-zip \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --src app.zip

# Clean up
rm app.zip

echo ""
echo "🎉 Deployment fixed and completed successfully!"
echo ""
echo "🌐 Application URLs:"
echo "==================="
echo "East US Web App: https://${WEB_APP_EAST}.azurewebsites.net"
echo "Central US Web App: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo "Traffic Manager: https://${TRAFFIC_MANAGER}.trafficmanager.net"
echo ""
echo "⚠️  Important Notes:"
echo "==================="
echo "1. It may take 5-10 minutes for the applications to fully start"
echo "2. The database will be initialized automatically on first access"
echo "3. Traffic Manager DNS propagation may take up to 5 minutes"
echo ""
echo "🧪 Test your deployment:"
echo "======================="
echo "1. Visit the Traffic Manager URL to test load balancing"
echo "2. Try adding, editing, and deleting items"
echo "3. Check the health endpoint: /health"