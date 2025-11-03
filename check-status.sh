#!/bin/bash

# Smart status checker for CRUD application deployments

echo "🔍 Checking Azure CRUD Application Status..."
echo "==========================================="

# Find all CRUD app resource groups
RESOURCE_GROUPS=$(az group list --query "[?starts_with(name, 'rg-crud-app-')].name" -o tsv)

if [ -z "$RESOURCE_GROUPS" ]; then
    echo "❌ No CRUD application deployments found."
    echo "Run ./deploy-simple.sh to create a new deployment."
    exit 0
fi

for RG in $RESOURCE_GROUPS; do
    echo ""
    echo "📋 Resource Group: $RG"
    echo "=====================$(echo $RG | sed 's/./=/g')"
    
    # Extract timestamp from resource group name
    TIMESTAMP=$(echo $RG | sed 's/rg-crud-app-//')
    
    # Check if resources exist
    WEB_APP_EAST="webapp-crud-east-${TIMESTAMP}"
    WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"
    TRAFFIC_MANAGER="tm-crud-${TIMESTAMP}"
    SQL_SERVER="sqlserver${TIMESTAMP}"
    
    echo "🌐 Application URLs:"
    echo "East US: https://${WEB_APP_EAST}.azurewebsites.net"
    echo "Central US: https://${WEB_APP_CENTRAL}.azurewebsites.net"
    echo "Traffic Manager: https://${TRAFFIC_MANAGER}.trafficmanager.net"
    echo "SQL Server: ${SQL_SERVER}.database.windows.net"
    
    # Test app status
    echo ""
    echo "🧪 Testing Application Status:"
    
    # Test East US
    EAST_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${WEB_APP_EAST}.azurewebsites.net/health" 2>/dev/null || echo "000")
    if [ "$EAST_STATUS" = "200" ]; then
        echo "✅ East US: Working (HTTP $EAST_STATUS)"
    else
        echo "❌ East US: Not working (HTTP $EAST_STATUS)"
    fi
    
    # Test Central US
    CENTRAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${WEB_APP_CENTRAL}.azurewebsites.net/health" 2>/dev/null || echo "000")
    if [ "$CENTRAL_STATUS" = "200" ]; then
        echo "✅ Central US: Working (HTTP $CENTRAL_STATUS)"
    else
        echo "❌ Central US: Not working (HTTP $CENTRAL_STATUS)"
    fi
    
    # Test Traffic Manager
    TM_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${TRAFFIC_MANAGER}.trafficmanager.net/health" 2>/dev/null || echo "000")
    if [ "$TM_STATUS" = "200" ]; then
        echo "✅ Traffic Manager: Working (HTTP $TM_STATUS)"
    else
        echo "❌ Traffic Manager: Not working (HTTP $TM_STATUS)"
    fi
    
    echo ""
    echo "🔧 Quick Fix Commands:"
    echo "Fix database: ./fix-database-connection.sh"
    echo "Check logs: az webapp log tail --name $WEB_APP_CENTRAL --resource-group $RG"
    echo "Restart apps: az webapp restart --name $WEB_APP_CENTRAL --resource-group $RG"
done

echo ""
echo "💡 Management Commands:"
echo "======================"
echo "Clean up all: ./cleanup.sh"
echo "New deployment: ./deploy-simple.sh"
echo "Azure Portal: https://portal.azure.com"