#!/usr/bin/env bash
set -euo pipefail

SUB_ID="<SUBSCRIPTION_ID>"
RG="<VM_RESOURCE_GROUP>"
VM="<VM_NAME>"

KV_NAME="<KEYVAULT_NAME>"
SERVER_SECRET="<AQUA_SERVER_SECRET_NAME>"
TOKEN_SECRET="<AQUA_TOKEN_SECRET_NAME>"

az account set --subscription "$SUB_ID"

az vm extension set \
  --resource-group "$RG" \
  --vm-name        "$VM" \
  --name           CustomScriptExtension \
  --publisher      Microsoft.Compute \
  --protected-settings '{
    "fileUris": [
      "<bootsctrap script url> "
    ],
    "commandToExecute": "powershell -ExecutionPolicy Bypass -File <bootstrap script name>.ps1 -KvName '"$KV_NAME"' -ServerSecret '"$SERVER_SECRET"' -TokenSecret '"$TOKEN_SECRET"'"
  }' \
  --output none

echo "Bootstrap extension applied to $VM."
