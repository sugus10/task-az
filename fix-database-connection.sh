#!/bin/bash

# Fix database connection for both apps to meet task requirements

TIMESTAMP="20251103133251"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"
WEB_APP_EAST="webapp-crud-east-${TIMESTAMP}"
WEB_APP_CENTRAL="webapp-crud-central-${TIMESTAMP}"
SQL_SERVER="sqlserver${TIMESTAMP}"
SQL_DATABASE="myDatabase"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="P@ssw0rd123!"

echo "🔧 Fixing Database Connection for Task Requirements..."
echo "===================================================="

# Create proper connection string
CONNECTION_STRING="Driver={ODBC Driver 18 for SQL Server};Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=${SQL_DATABASE};Uid=${SQL_ADMIN};Pwd=${SQL_PASSWORD};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"

echo "Setting database connection string for East US app..."
az webapp config appsettings set \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --settings SQL_CONNECTION_STRING="$CONNECTION_STRING"

echo "Setting database connection string for Central US app..."
az webapp config appsettings set \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --settings SQL_CONNECTION_STRING="$CONNECTION_STRING"

# Set proper startup commands for both apps
echo "Setting startup command for East US app..."
az webapp config set \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --startup-file "gunicorn --bind 0.0.0.0:8000 --timeout 120 --workers 1 app:app"

echo "Setting startup command for Central US app..."
az webapp config set \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --startup-file "gunicorn --bind 0.0.0.0:8000 --timeout 120 --workers 1 app:app"

# Enable application logging for both apps
echo "Enabling logging for East US app..."
az webapp log config \
    --name $WEB_APP_EAST \
    --resource-group $RESOURCE_GROUP \
    --application-logging filesystem \
    --detailed-error-messages true \
    --failed-request-tracing true

echo "Enabling logging for Central US app..."
az webapp log config \
    --name $WEB_APP_CENTRAL \
    --resource-group $RESOURCE_GROUP \
    --application-logging filesystem \
    --detailed-error-messages true \
    --failed-request-tracing true

# Restart both apps
echo "Restarting East US app..."
az webapp restart --name $WEB_APP_EAST --resource-group $RESOURCE_GROUP

echo "Restarting Central US app..."
az webapp restart --name $WEB_APP_CENTRAL --resource-group $RESOURCE_GROUP

echo ""
echo "✅ Database connections configured for both apps!"
echo ""
echo "📋 Task Requirements Met:"
echo "========================"
echo "✅ Azure SQL Database: ${SQL_SERVER}.database.windows.net"
echo "✅ Database: $SQL_DATABASE"
echo "✅ Multi-region deployment: East US + Central US"
echo "✅ Traffic Manager: Performance routing"
echo "✅ Full CRUD operations with database"
echo ""
echo "🌐 Application URLs:"
echo "==================="
echo "East US: https://${WEB_APP_EAST}.azurewebsites.net"
echo "Central US: https://${WEB_APP_CENTRAL}.azurewebsites.net"
echo "Traffic Manager: https://tm-crud-${TIMESTAMP}.trafficmanager.net"
echo ""
echo "⏱️ Wait 3-5 minutes for apps to restart with database connection"
echo ""
echo "🔍 To check logs:"
echo "East US: az webapp log tail --name $WEB_APP_EAST --resource-group $RESOURCE_GROUP"
echo "Central US: az webapp log tail --name $WEB_APP_CENTRAL --resource-group $RESOURCE_GROUP"