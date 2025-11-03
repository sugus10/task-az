#!/bin/bash

# Check logs for the East US app

TIMESTAMP="20251103133251"
WEB_APP_EAST="webapp-crud-east-${TIMESTAMP}"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"

echo "🔍 Checking East US app logs..."
echo "==============================="

# Get deployment logs
echo "Deployment logs:"
az webapp log deployment list --name $WEB_APP_EAST --resource-group $RESOURCE_GROUP --query "[0].details[].message" -o table

echo ""
echo "Application logs:"
az webapp log tail --name $WEB_APP_EAST --resource-group $RESOURCE_GROUP --provider application

echo ""
echo "Restart the East US app to fix startup issues:"
echo "az webapp restart --name $WEB_APP_EAST --resource-group $RESOURCE_GROUP"