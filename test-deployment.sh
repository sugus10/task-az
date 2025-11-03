#!/bin/bash

# Test script to verify the deployment is working

TIMESTAMP="20251103133251"
WEB_APP_EAST="webapp-crud-east-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"
TRAFFIC_MANAGER="tm-crud-${TIMESTAMP}"

echo "🧪 Testing Azure CRUD Application Deployment"
echo "============================================="

echo ""
echo "Testing East US Web App..."
curl -s -o /dev/null -w "Status: %{http_code}\n" "https://${WEB_APP_EAST}.azurewebsites.net/health" || echo "East US app not ready yet"

echo ""
echo "Testing Central US Web App..."
curl -s -o /dev/null -w "Status: %{http_code}\n" "https://${WEB_APP_CENTRAL}.azurewebsites.net/health" || echo "Central US app not ready yet"

echo ""
echo "Testing Traffic Manager..."
curl -s -o /dev/null -w "Status: %{http_code}\n" "https://${TRAFFIC_MANAGER}.trafficmanager.net/health" || echo "Traffic Manager not ready yet"

echo ""
echo "🌐 Your Application URLs:"
echo "========================"
echo "East US: https://${WEB_APP_EAST}.azurewebsites.net"
echo "Central US: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo "Traffic Manager: https://${TRAFFIC_MANAGER}.trafficmanager.net"
echo ""
echo "💡 Note: Apps may take 5-10 minutes to fully start after deployment"