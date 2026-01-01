#!/usr/bin/env bash
set -e

API_BASE_URL="${API_BASE_URL:-https://omniutil.onrender.com}"
VERCEL_URL="${VERCEL_URL:-https://omniutil.vercel.app}"

API_KEY="$(grep '^API_KEY=' backend/.env | cut -d= -f2-)"

echo "🧪 OmniUtil — Test API Global"
echo "Backend: $API_BASE_URL"
echo "Frontend: $VERCEL_URL"
echo

echo "1️⃣ Health check backend"
curl -fs "$API_BASE_URL/health" && echo " ✅ OK" || echo " ❌ FAIL"
echo

echo "2️⃣ AI sans clé (doit échouer)"
curl -s -o /dev/null -w "%{http_code}\n" "$API_BASE_URL/api/ai"
echo

echo "3️⃣ AI avec clé valide"
curl -fs -H "x-api-key: $API_KEY" "$API_BASE_URL/api/ai" && echo " ✅ OK" || echo " ❌ FAIL"
echo

echo "4️⃣ AI status"
curl -fs -H "x-api-key: $API_KEY" "$API_BASE_URL/api/ai/status" && echo " ✅ OK"
echo

echo "5️⃣ Frontend Vercel accessible"
curl -fs "$VERCEL_URL" > /dev/null && echo " ✅ OK"

echo
echo "🎉 Tests API OmniUtil TERMINÉS"
