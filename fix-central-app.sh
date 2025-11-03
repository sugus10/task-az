#!/bin/bash

# Fix the Central US app that's stuck on startup

TIMESTAMP="20251103133251"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"

echo "🔧 Fixing Central US app startup..."
echo "=================================="

# Set explicit startup command
echo "Setting startup command..."
az webapp config set \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --startup-file "python app.py"

# Set Python version explicitly
echo "Setting Python version..."
az webapp config set \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --linux-fx-version "PYTHON|3.11"

# Enable logging
echo "Enabling application logging..."
az webapp log config \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --application-logging filesystem

# Restart the app
echo "Restarting Central US app..."
az webapp restart --name $WEB_APP_CENTRAL --resource-group $RESOURCE_GROUP

echo ""
echo "✅ Central US app restart initiated!"
echo "Wait 2-3 minutes and test: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo ""
echo "🔍 To check logs:"
echo "az webapp log tail --name $WEB_APP_CENTRAL --resource-group $RESOURCE_GROUP"