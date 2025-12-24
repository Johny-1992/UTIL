#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="/root/omniutil/backend"
API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:3000}"

cd "$BACKEND_DIR"

# Récupérer la clé API depuis .env si pas déjà dans l'env
API_KEY_CLIENT="${API_KEY_CLIENT:-}"
if [ -z "$API_KEY_CLIENT" ]; then
  API_KEY_CLIENT="$(grep '^API_KEY=' .env | cut -d= -f2- || true)"
fi

echo "=== Tests API omniutil ==="
echo "Base URL : $API_BASE_URL"
echo "API_KEY_CLIENT : ${API_KEY_CLIENT:0:8}... (masquée)"

echo
echo "1) /health (public) :"
curl -i "$API_BASE_URL/health" || true

echo
echo "----------------------------------------"
echo "2) /api/ai sans clé (doit être 401) :"
curl -i "$API_BASE_URL/api/ai" || true

echo
echo "----------------------------------------"
echo "3) /api/ai avec MAUVAISE clé (doit être 401) :"
curl -i \
  -H "x-api-key: CLE_INVALIDE_123" \
  "$API_BASE_URL/api/ai" || true

echo
echo "----------------------------------------"
echo "4) /api/ai avec la BONNE clé (doit être 200) :"
curl -i \
  -H "x-api-key: $API_KEY_CLIENT" \
  "$API_BASE_URL/api/ai" || true

echo
echo "----------------------------------------"
echo "5) /api/ai/status avec la BONNE clé (doit être 200) :"
curl -i \
  -H "x-api-key: $API_KEY_CLIENT" \
  "$API_BASE_URL/api/ai/status" || true

echo
echo "=== Fin des tests API omniutil ==="
