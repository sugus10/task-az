#!/bin/bash

# Deploy minimal working version

TIMESTAMP="20251103145006"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"

echo "🚀 Deploying Minimal Working Version"
echo "===================================="

# Backup original files
mv app.py app-database.py
mv requirements.txt requirements-database.txt

# Use minimal versions
mv app-minimal.py app.py
mv requirements-minimal.txt requirements.txt

# Deploy
echo "Deploying minimal working app..."
az webapp up \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --runtime "PYTHON|3.11" \
    --location "centralus"

echo ""
echo "✅ Minimal version deployed!"
echo ""
echo "🧪 Test immediately:"
echo "Main app: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo "Health: https://${WEB_APP_CENTRAL}.azurewebsites.net/health"
echo "Debug: https://${WEB_APP_CENTRAL}.azurewebsites.net/debug"
echo ""
echo "📋 Features:"
echo "✅ Full CRUD operations"
echo "✅ Bootstrap UI"
echo "✅ In-memory storage (works immediately)"
echo "✅ Multi-region ready"