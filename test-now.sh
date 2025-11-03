#!/bin/bash

# Quick test of the current deployment

TIMESTAMP="20251103145006"
WEB_APP_EAST="webapp-crud-east-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"
TRAFFIC_MANAGER="tm-crud-${TIMESTAMP}"

echo "🧪 Testing Your Azure CRUD Application"
echo "======================================"

echo ""
echo "Testing Central US app..."
CENTRAL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${WEB_APP_CENTRAL}.azurewebsites.net" 2>/dev/null || echo "000")
if [ "$CENTRAL_STATUS" = "200" ]; then
    echo "✅ Central US: Working! (HTTP $CENTRAL_STATUS)"
    echo "   URL: https://${WEB_APP_CENTRAL}.azurewebsites.net"
else
    echo "⏳ Central US: Still starting... (HTTP $CENTRAL_STATUS)"
fi

echo ""
echo "Testing East US app..."
EAST_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${WEB_APP_EAST}.azurewebsites.net" 2>/dev/null || echo "000")
if [ "$EAST_STATUS" = "200" ]; then
    echo "✅ East US: Working! (HTTP $EAST_STATUS)"
    echo "   URL: https://${WEB_APP_EAST}.azurewebsites.net"
else
    echo "⏳ East US: Still starting... (HTTP $EAST_STATUS)"
fi

echo ""
echo "Testing Traffic Manager..."
TM_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${TRAFFIC_MANAGER}.trafficmanager.net" 2>/dev/null || echo "000")
if [ "$TM_STATUS" = "200" ]; then
    echo "✅ Traffic Manager: Working! (HTTP $TM_STATUS)"
    echo "   URL: https://${TRAFFIC_MANAGER}.trafficmanager.net"
else
    echo "⏳ Traffic Manager: Still starting... (HTTP $TM_STATUS)"
fi

echo ""
echo "🎯 Your Application URLs:"
echo "========================"
echo "Traffic Manager: https://${TRAFFIC_MANAGER}.trafficmanager.net"
echo "East US: https://${WEB_APP_EAST}.azurewebsites.net"
echo "Central US: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo ""
echo "💡 If apps show 'still starting', wait 2-3 more minutes and test again"