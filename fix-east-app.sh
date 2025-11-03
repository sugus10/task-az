#!/bin/bash

# Fix the East US app startup issue

TIMESTAMP="20251103133251"
WEB_APP_EAST="webapp-crud-east-${TIMESTAMP}"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"

echo "🔧 Fixing East US app..."
echo "======================="

# Set the startup command explicitly
echo "Setting startup command..."
az webapp config set \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --startup-file "gunicorn --bind 0.0.0.0:8000 --timeout 120 app:app"

# Restart the app
echo "Restarting East US app..."
az webapp restart --name $WEB_APP_EAST --resource-group $RESOURCE_GROUP

echo ""
echo "✅ East US app restart initiated!"
echo "Wait 2-3 minutes and test: https://${WEB_APP_EAST}.azurewebsites.net"
echo ""
echo "🌐 Your Working URLs:"
echo "===================="
echo "Central US (Working): https://webapp-crud-central-${TIMESTAMP}.azurewebsites.net"
echo "Traffic Manager: https://tm-crud-${TIMESTAMP}.trafficmanager.net"