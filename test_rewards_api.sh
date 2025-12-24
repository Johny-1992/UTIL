#!/usr/bin/env bash
set -euo pipefail

# Définis explicitement l'URL de base
API_BASE_URL="http://127.0.0.1:3000"

# Récupère la clé API depuis .env
API_KEY_CLIENT="$(grep '^API_KEY=' /root/omniutil/backend/.env | cut -d= -f2- | tr -d ' \r\n')"

echo "=== Tests API /api/rewards ==="
echo "Base URL : $API_BASE_URL"
echo "Clé API extraite : '$API_KEY_CLIENT'"
echo

# Test 1 : /api/rewards/calculate SANS clé (doit échouer avec 401)
echo "1) /api/rewards/calculate SANS clé (doit être 401) :"
curl -v -i \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"partnerId": "p1", "userId": "u1", "amountSpent": 100, "currency": "USD", "utilPrice": 0.5}' \
  "$API_BASE_URL/api/rewards/calculate" || true
echo
echo "----------------------------------------"

# Test 2 : /api/rewards/calculate AVEC clé (doit réussir avec 200)
echo "2) /api/rewards/calculate AVEC clé (doit être 200) :"
curl -v -i \
  -X POST \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY_CLIENT" \
  -d '{"partnerId": "p1", "userId": "u1", "amountSpent": 100, "currency": "USD", "utilPrice": 0.5}' \
  "$API_BASE_URL/api/rewards/calculate" || true
echo
echo "----------------------------------------"

# Test 3 : /api/rewards/transfer AVEC clé (doit réussir avec 200)
echo "3) /api/rewards/transfer AVEC clé (doit être 200) :"
curl -v -i \
  -X POST \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY_CLIENT" \
  -d '{"fromUserId": "u1", "toUserId": "u2", "amount": 10}' \
  "$API_BASE_URL/api/rewards/transfer" || true
echo
echo "----------------------------------------"

# Test 4 : /api/rewards/convert AVEC clé (doit réussir avec 200)
echo "4) /api/rewards/convert AVEC clé (doit être 200) :"
curl -v -i \
  -X POST \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY_CLIENT" \
  -d '{"userId": "u1", "amount": 5}' \
  "$API_BASE_URL/api/rewards/convert" || true
echo
echo "=== Fin des tests /api/rewards ==="
