#!/bin/bash

# Cleanup script for failed deployments
echo "Cleaning up failed deployment resources..."

# Get the resource group name from the failed deployment
RESOURCE_GROUP="rg-crud-app-20251103132617"

echo "Deleting resource group: $RESOURCE_GROUP"
az group delete --name $RESOURCE_GROUP --yes --no-wait

echo "Cleanup initiated. Resources will be deleted in the background."
echo "You can now run the new deployment script."