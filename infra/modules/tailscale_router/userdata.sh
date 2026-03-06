#!/usr/bin/env bash
set -euo pipefail

TAILNET="${tailnet}"
CLIENT_ID="${oauth_client_id}"
CLIENT_SECRET="${oauth_client_secret}"
ROUTES="${routes}"
HOSTNAME="${hostname}"

apt-get update -y
apt-get install -y curl jq

curl -fsSL https://tailscale.com/install.sh | sh

TOKEN=$(curl -fsS -u "$CLIENT_ID:$CLIENT_SECRET" \
  -d "grant_type=client_credentials" \
  "https://api.tailscale.com/api/v2/oauth/token" | jq -r .access_token)

AUTHKEY=$(curl -fsS -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"capabilities":{"devices":{"create":{"reusable":false,"ephemeral":true,"preauthorized":true,"tags":["tag:subnet-router"]}}}}' \
  "https://api.tailscale.com/api/v2/tailnet/$TAILNET/keys" | jq -r .key)

tailscale up \
  --authkey="$AUTHKEY" \
  --hostname="$HOSTNAME" \
  --advertise-routes="$ROUTES" \
  --accept-dns=false \
  --ssh

systemctl enable --now tailscaled
