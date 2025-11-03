#!/bin/bash

# Direct fix for the application errors

TIMESTAMP="20251103145006"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"
WEB_APP_EAST="webapp-crud-east-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"
SQL_SERVER="sqlserver${TIMESTAMP}"
SQL_DATABASE="myDatabase"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="P@ssw0rd123!"

echo "🔧 Direct Fix for Application Errors"
echo "===================================="

# Create the exact connection string
CONNECTION_STRING="Driver={ODBC Driver 18 for SQL Server};Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=${SQL_DATABASE};Uid=${SQL_ADMIN};Pwd=${SQL_PASSWORD};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"

echo "Setting connection string for East US..."
az webapp config appsettings set \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --settings "SQL_CONNECTION_STRING=${CONNECTION_STRING}"

echo "Setting connection string for Central US..."
az webapp config appsettings set \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --settings "SQL_CONNECTION_STRING=${CONNECTION_STRING}"

# Also set a simpler startup command
echo "Setting simpler startup command..."
az webapp config set \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --startup-file "python app.py"

az webapp config set \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --startup-file "python app.py"

# Restart both apps
echo "Restarting apps..."
az webapp restart --name $WEB_APP_EAST --resource-group $RESOURCE_GROUP
az webapp restart --name $WEB_APP_CENTRAL --resource-group $RESOURCE_GROUP

echo ""
echo "✅ Fix applied! Wait 3-5 minutes and test:"
echo "Central US: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo "East US: https://${WEB_APP_EAST}.azurewebsites.net"
echo "Traffic Manager: https://tm-crud-${TIMESTAMP}.trafficmanager.net"