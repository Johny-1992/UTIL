#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="/root/omniutil/backend"
API_BASE="http://127.0.0.1:3000"

echo "=== OMNIUTIL API CORE TEST (step 8) ==="
cd "$BACKEND_DIR"

# 1) Charger la clé API
echo
echo "[1] Lecture de la clé API dans .env"
API_KEY="$(grep '^API_KEY=' .env | cut -d= -f2- || true)"
if [ -z "$API_KEY" ]; then
  echo "[ERREUR] API_KEY absente dans .env"
  exit 1
fi
echo "[OK] API_KEY chargée (masquée) : ${API_KEY:0:6}... (len=${#API_KEY})"

# 2) Tester /health direct backend
echo
echo "[2] Test /health direct sur $API_BASE/health"
curl -sS "$API_BASE/health" && echo

# 3) Test /api/reward/compute
echo
echo "[3] Test POST /api/reward/compute avec clé"
curl -sS -i \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"usage": 100, "rate": 1.5}' \
  "$API_BASE/api/reward/compute"
echo

# 4) Test /api/partner/onboard (accepted)
echo
echo "[4] Test POST /api/partner/onboard (score=90, doit être accepté)"
curl -sS -i \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","score": 90}' \
  "$API_BASE/api/partner/onboard"
echo

# 5) Test /api/partner/onboard (rejected)
echo
echo "[5] Test POST /api/partner/onboard (score=50, doit être rejeté)"
curl -sS -i \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","score": 50}' \
  "$API_BASE/api/partner/onboard"
echo

# 6) Test /api/util/exchange
echo
echo "[6] Test POST /api/util/exchange"
curl -sS -i \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"user":"alice","service":"hotel","amount": 50}' \
  "$API_BASE/api/util/exchange"
echo

echo
echo "=== FIN TEST API CORE (step 8) ==="
