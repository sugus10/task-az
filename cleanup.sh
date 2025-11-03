#!/bin/bash

# Smart cleanup script that automatically detects CRUD app resource groups
echo "🔍 Detecting Azure CRUD Application resource groups..."
echo "===================================================="

# Find all resource groups that match our naming pattern
RESOURCE_GROUPS=$(az group list --query "[?starts_with(name, 'rg-crud-app-')].name" -o tsv)

if [ -z "$RESOURCE_GROUPS" ]; then
    echo "❌ No CRUD application resource groups found."
    echo "Nothing to clean up."
    exit 0
fi

echo "📋 Found the following CRUD application resource groups:"
echo "$RESOURCE_GROUPS" | nl

echo ""
echo "🗑️  Cleaning up resources..."
echo "=========================="

# Delete each resource group
for RG in $RESOURCE_GROUPS; do
    echo "Deleting resource group: $RG"
    az group delete --name "$RG" --yes --no-wait
    echo "✅ Deletion initiated for: $RG"
done

echo ""
echo "🎉 Cleanup Summary:"
echo "=================="
echo "$(echo "$RESOURCE_GROUPS" | wc -l) resource group(s) scheduled for deletion"
echo "Resources will be deleted in the background (5-10 minutes)"
echo ""
echo "📋 Deleted Resource Groups:"
echo "$RESOURCE_GROUPS"
echo ""
echo "✅ You can now run a new deployment script!"
echo ""
echo "💡 To check deletion status:"
echo "az group list --query \"[?starts_with(name, 'rg-crud-app-')].{Name:name, Status:properties.provisioningState}\" -o table"