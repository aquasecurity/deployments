#!/usr/bin/env bash
set -euo pipefail

ServerSecret="<AQUA_SERVER_SECRET_NAME>"
TokenSecret="<AQUA_TOKEN_SECRET_NAME>"

IMDS_TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" \
             -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
REGION="${AWS_REGION:-$(
  curl -sS -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" \
       http://169.254.169.254/latest/meta-data/placement/region
)}"

CONFIG_DIR="/opt/aquasec"
TMP_FILE="${CONFIG_DIR}/.config.tmp"
FINAL_FILE="${CONFIG_DIR}/GI_AQUA_CONFIG-prod_env.json"

sudo apt-get update -y
sudo apt-get install -y docker.io jq
sudo systemctl start docker

fetch_secret () {
  local secret_id="$1"
  sudo docker run --rm public.ecr.aws/aws-cli/aws-cli \
       secretsmanager get-secret-value \
       --secret-id "$secret_id" \
       --region "$REGION" \
       --query SecretString --output text
}

RAW_SERVER_JSON=$(fetch_secret "$ServerSecret")
RAW_TOKEN_JSON=$(fetch_secret "$TokenSecret")

AQUA_SERVER=$(jq -r '.AQUA_SERVER' <<<"$RAW_SERVER_JSON")
AQUA_TOKEN=$(jq -r '.AQUA_TOKEN' <<<"$RAW_TOKEN_JSON")

jq -n --arg s "$AQUA_SERVER" --arg t "$AQUA_TOKEN" \
      '{AQUA_SERVER:$s, AQUA_TOKEN:$t}' > "$TMP_FILE"
sudo mv "$TMP_FILE" "$FINAL_FILE"
