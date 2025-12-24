#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="/root/omniutil/backend"
API_BASE_HTTP="http://127.0.0.1:8080"
API_BASE_HTTPS="https://127.0.0.1:8443"

echo "=== OMNIUTIL SELFCHECK ==="
echo "[*] Dossier backend : $BACKEND_DIR"

cd "$BACKEND_DIR"

############################################
# 1) Vérifier Node, npm, pm2
############################################
echo
echo "[1] Versions Node / npm / pm2"
if command -v node >/dev/null 2>&1; then
  echo -n "node: " && node -v
else
  echo "[ERREUR] node non trouvé dans le PATH"
fi

if command -v npm >/dev/null 2>&1; then
  echo -n "npm: " && npm -v
else
  echo "[ERREUR] npm non trouvé dans le PATH"
fi

if command -v pm2 >/dev/null 2>&1; then
  echo -n "pm2: " && pm2 -v
else
  echo "[ERREUR] pm2 non trouvé dans le PATH"
fi

############################################
# 2) Vérifier compilation TypeScript
############################################
echo
echo "[2] Compilation TypeScript (npx tsc --noEmit pour vérifier)..."
if npx tsc --noEmit; then
  echo "[OK] TypeScript compile sans erreur."
else
  echo "[ERREUR] TypeScript ne compile pas. Corrige les erreurs ci-dessus."
  exit 1
fi

############################################
# 3) Vérifier PM2 / process omniutil-api
############################################
echo
echo "[3] Statut PM2"
pm2 status || echo "[WARN] pm2 status a retourné une erreur (mais on continue)."

if pm2 describe omniutil-api >/dev/null 2>&1; then
  echo "[OK] Process 'omniutil-api' trouvé."
else
  echo "[WARN] Process 'omniutil-api' introuvable, tentative de démarrage..."
  pm2 start dist/index.js --name omniutil-api
  pm2 save
fi

############################################
# 4) Lecture de la clé API
############################################
echo
echo "[4] Lecture de la clé API depuis .env"
API_KEY="$(grep '^API_KEY=' .env | cut -d= -f2- || true)"

if [ -z "$API_KEY" ]; then
  echo "[ERREUR] API_KEY absente dans .env"
  exit 1
fi

echo "[OK] API_KEY chargée (masquée) : ${API_KEY:0:6}... (longueur = ${#API_KEY})"

############################################
# 5) Test /health via HTTP (8080)
############################################
echo
echo "[5] Test HTTP via Nginx (port 8080) → /health"
HTTP_HEALTH="$(curl -sS "$API_BASE_HTTP/health" || true)"
echo "Réponse /health (HTTP) : $HTTP_HEALTH"

if [[ "$HTTP_HEALTH" == *"status"* ]]; then
  echo "[OK] /health (HTTP 8080) répond correctement."
else
  echo "[WARN] /health (HTTP 8080) ne renvoie pas la structure attendue."
fi

############################################
# 6) Test /health via HTTPS (8443)
############################################
echo
echo "[6] Test HTTPS via Nginx (port 8443, cert auto-signé) → /health"
HTTPS_HEALTH="$(curl -k -sS "$API_BASE_HTTPS/health" || true)"
echo "Réponse /health (HTTPS) : $HTTPS_HEALTH"

if [[ "$HTTPS_HEALTH" == *"status"* ]]; then
  echo "[OK] /health (HTTPS 8443) répond correctement."
else
  echo "[WARN] /health (HTTPS 8443) ne renvoie pas la structure attendue."
fi

############################################
# 7) Test /api/ai/status SANS clé (doit être 401)
############################################
echo
echo "[7] Test /api/ai/status SANS clé"

STATUS_NO_KEY_HTTP="$(curl -sS -o /dev/null -w "%{http_code}" "$API_BASE_HTTP/api/ai/status" || true)"
STATUS_NO_KEY_HTTPS="$(curl -k -sS -o /dev/null -w "%{http_code}" "$API_BASE_HTTPS/api/ai/status" || true)"

echo " - HTTP  (8080)  attendu = 401, reçu = $STATUS_NO_KEY_HTTP"
echo " - HTTPS (8443)  attendu = 401, reçu = $STATUS_NO_KEY_HTTPS"

############################################
# 8) Test /api/ai/status AVEC clé (doit être 200)
############################################
echo
echo "[8] Test /api/ai/status AVEC clé"

STATUS_WITH_KEY_HTTP="$(curl -sS -o /dev/null -w "%{http_code}" \
  -H "x-api-key: $API_KEY" \
  "$API_BASE_HTTP/api/ai/status" || true)"

STATUS_WITH_KEY_HTTPS="$(curl -k -sS -o /dev/null -w "%{http_code}" \
  -H "x-api-key: $API_KEY" \
  "$API_BASE_HTTPS/api/ai/status" || true)"

echo " - HTTP  (8080)  attendu = 200, reçu = $STATUS_WITH_KEY_HTTP"
echo " - HTTPS (8443)  attendu = 200, reçu = $STATUS_WITH_KEY_HTTPS"

############################################
# 9) Test Rate Limit (HTTP 8080)
############################################
echo
echo "[9] Test Rate Limit sur /api/ai/status (HTTP 8080) avec 70 requêtes"

CODES=""
for i in $(seq 1 70); do
  CODE="$(curl -sS -o /dev/null -w "%{http_code}" \
    -H "x-api-key: $API_KEY" \
    "$API_BASE_HTTP/api/ai/status" || true)"
  CODES="$CODES[$CODE]"
done
echo "Codes renvoyés :"
echo "$CODES"
echo
echo "=> On s'attend à ~60 fois [200] puis plusieurs [429] (Too Many Requests)."

echo
echo "=== SELFCHECK TERMINE ==="
