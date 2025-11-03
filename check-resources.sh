#!/bin/bash

# Check what resources actually exist

TIMESTAMP="20251103145006"
RESOURCE_GROUP="rg-crud-app-${TIMESTAMP}"

echo "🔍 Checking Existing Resources"
echo "=============================="

echo "Resource Group: $RESOURCE_GROUP"
echo ""

echo "All resources in the group:"
az resource list --resource-group $RESOURCE_GROUP --output table

echo ""
echo "SQL Servers (if any):"
az sql server list --resource-group $RESOURCE_GROUP --output table

echo ""
echo "Web Apps:"
az webapp list --resource-group $RESOURCE_GROUP --query "[].{Name:name, State:state, Location:location}" --output table