#!/bin/bash

# Quick test and troubleshoot script

TIMESTAMP="20251103133251"
WEB_APP_EAST="webapp-crud-east-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"

echo "🔍 Quick Troubleshooting..."
echo "=========================="

# Check if the apps are running
echo "Checking East US app status..."
az webapp show --name $WEB_APP_EAST --resource-group $RESOURCE_GROUP --query "state" -o tsv

echo "Checking Central US app status..."
az webapp show --name $WEB_APP_CENTRAL --resource-group $RESOURCE_GROUP --query "state" -o tsv

# Test direct access
echo ""
echo "Testing direct access..."
echo "East US: https://${WEB_APP_EAST}.azurewebsites.net"
curl -I "https://${WEB_APP_EAST}.azurewebsites.net" 2>/dev/null | head -1 || echo "Not responding yet"

echo "Central US: https://${WEB_APP_CENTRAL}.azurewebsites.net"
curl -I "https://${WEB_APP_CENTRAL}.azurewebsites.net" 2>/dev/null | head -1 || echo "Not responding yet"

# Check logs
echo ""
echo "Getting recent logs from East US app..."
az webapp log tail --name $WEB_APP_EAST --resource-group $RESOURCE_GROUP --provider application --lines 10

echo ""
echo "🌐 Your URLs:"
echo "============="
echo "Traffic Manager: https://tm-crud-${TIMESTAMP}.trafficmanager.net"
echo "East US: https://${WEB_APP_EAST}.azurewebsites.net"
echo "Central US: https://${WEB_APP_CENTRAL}.azurewebsites.net"