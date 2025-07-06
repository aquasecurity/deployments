#!/usr/bin/env bash
set -euo pipefail

# ── 0 ▪ validate required env-vars ──────────────────────────────────────────────
: "${KV_NAME:?Missing KV_NAME}"
: "${SERVER_SECRET:?Missing SERVER_SECRET}"
: "${TOKEN_SECRET:?Missing TOKEN_SECRET}"

CONFIG_DIR=/opt/aquasec
TMP_FILE="$CONFIG_DIR/.config.tmp"
FINAL_FILE="$CONFIG_DIR/GI_AQUA_CONFIG-prod_env.json"

# ── 1 ▪ get an IMDS token for Key Vault ─────────────────────────────────────────
IMDS_TOKEN=$(curl -sf -H Metadata:true \
  "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=https://vault.azure.net" \
  | jq -r .access_token)

# ── 2 ▪ fetch secrets whose names came from the launcher ────────────────────────
AQUA_SERVER=$(curl -sf -H "Authorization: Bearer $IMDS_TOKEN" \
  "https://${KV_NAME}.vault.azure.net/secrets/${SERVER_SECRET}?api-version=7.3" \
  | jq -r .value)

AQUA_TOKEN=$(curl -sf -H "Authorization: Bearer $IMDS_TOKEN" \
  "https://${KV_NAME}.vault.azure.net/secrets/${TOKEN_SECRET}?api-version=7.3" \
  | jq -r .value)

# ── 3 ▪ write config atomically and lock it down ───────────────────────────────
mkdir -p "$CONFIG_DIR"
if ! command -v jq >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y jq
  elif command -v yum >/dev/null 2>&1; then
    yum install -y jq
  else
    exit 1
  fi
fi
jq -n --arg s "$AQUA_SERVER" --arg t "$AQUA_TOKEN" \
  '{AQUA_SERVER:$s, AQUA_TOKEN:$t}' > "$TMP_FILE"

chmod 600 "$TMP_FILE"
mv "$TMP_FILE" "$FINAL_FILE"
