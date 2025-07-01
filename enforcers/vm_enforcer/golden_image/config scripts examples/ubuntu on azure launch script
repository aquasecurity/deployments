#!/usr/bin/env bash
set -euo pipefail

# ── 0 ▪ FILL IN YOUR VALUES ────────────────────────────────────────────────────
SUB_ID="<SUBSCRIPTION_ID>"
RG="<VM_RESOURCE_GROUP>"
VM="<VM_NAME>"

KV_NAME="<KEYVAULT_NAME>"
SERVER_SECRET="<AQUA_SERVER_SECRET_NAME>"
TOKEN_SECRET="<AQUA_TOKEN_SECRET_NAME>"

# ── 1 ▪ select subscription ────────────────────────────────────────────────────
az account set --subscription "$SUB_ID"

# ── 2 ▪ deploy / update the Custom Script Extension ────────────────────────────
az vm extension set \
  --resource-group "$RG" \
  --vm-name        "$VM" \
  --name           CustomScript \
  --publisher      Microsoft.Azure.Extensions \
  --version        2.1 \
  --protected-settings '{
    "fileUris": [
      "<bootstrap-aqua.sh script file url>"
    ],
    "commandToExecute": "bash -c '\''export KV_NAME='"$KV_NAME"' \
SERVER_SECRET='"$SERVER_SECRET"' TOKEN_SECRET='"$TOKEN_SECRET"' && bash <bootstrap-aqua.sh>'\''"
  }' \
  --output none

echo "Bootstrap extension applied to $VM."
