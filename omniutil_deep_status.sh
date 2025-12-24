#!/usr/bin/env bash
# Diagnostic global Omniutil – version stable
set -e

echo "============================================================"
echo " OMNIUTIL DEEP STATUS – DIAGNOSTIC GLOBAL"
echo "============================================================"

BASE_DIR="$(cd "$(dirname "\$0")" && pwd)"
BACKEND_DIR="$BASE_DIR/backend"
NGINX_CONF="$BASE_DIR/nginx_omniutil_local.conf"

echo "[*] BASE_DIR    = $BASE_DIR"
echo "[*] BACKEND_DIR = $BACKEND_DIR"
echo

if [ ! -d "$BACKEND_DIR" ]; then
  echo "[!] Dossier backend introuvable : $BACKEND_DIR"
  exit 1
fi

cd "$BACKEND_DIR"

# ------------------------------------------------------------------
# 1) ENVIRONNEMENT : Node / npm / pm2 / TypeScript
# ------------------------------------------------------------------
echo "------------------------------------------------------------"
echo "[1] ENVIRONNEMENT RUNTIME"
echo "------------------------------------------------------------"
NODE_VERSION="$(node -v 2>/dev/null || echo 'node ?')"
NPM_VERSION="$(npm -v 2>/dev/null || echo 'npm ?')"
PM2_VERSION="$(pm2 -v 2>/dev/null || echo 'pm2 ?')"

echo " - node : $NODE_VERSION"
echo " - npm  : $NPM_VERSION"
echo " - pm2  : $PM2_VERSION"
echo

echo " >> Vérification TypeScript (npx tsc --noEmit)..."
if npx tsc --noEmit >/tmp/omniutil_tsc_check.log 2>&1; then
  echo " [OK] TypeScript compile sans erreur."
else
  echo " [!] Erreurs TypeScript détectées (voir /tmp/omniutil_tsc_check.log)."
fi

# ------------------------------------------------------------------
# 2) CONFIGURATION .env / API_KEY
# ------------------------------------------------------------------
echo
echo "------------------------------------------------------------"
echo "[2] CONFIGURATION .env / API_KEY"
echo "------------------------------------------------------------"

if [ -f ".env" ]; then
  echo " - .env trouvé à : $BACKEND_DIR/.env"
  API_KEY="$(grep -m1 '^API_KEY' .env | cut -d= -f2- || true)"
  if [ -n "$API_KEY" ]; then
    LEN=${#API_KEY}
    MASK="${API_KEY:0:8}... (longueur = ${LEN})"
    echo " [OK] API_KEY chargée (masquée) : $MASK"
  else
    echo " [!] API_KEY absente de .env"
  fi
else
  echo " [!] Fichier .env introuvable dans $BACKEND_DIR"
fi

# ------------------------------------------------------------------
# 3) STRUCTURE BACKEND : index.ts + router AI
# ------------------------------------------------------------------
echo
echo "------------------------------------------------------------"
echo "[3] STRUCTURE BACKEND (index.ts, router AI)"
echo "------------------------------------------------------------"

if [ -f "src/index.ts" ]; then
  echo " - src/index.ts (extrait) :"
  sed -n '1,80p' src/index.ts | sed 's/^/ | /'
else
  echo " [!] src/index.ts introuvable."
fi

AI_TS=""
if [ -f "src/api/ai.ts" ]; then
  AI_TS="src/api/ai.ts"
elif [ -f "ai.ts" ]; then
  AI_TS="ai.ts"
fi

if [ -n "$AI_TS" ]; then
  echo
  echo " - Fichier AI détecté : $AI_TS (extrait) :"
  sed -n '1,120p' "$AI_TS" | sed 's/^/ | /'
  echo
  echo "   > Routes détectées dans $AI_TS :"
  # On liste simplement les lignes avec router.get/post/etc.
  grep -n "router\.$get\|post\|put\|delete$" "$AI_TS" || echo "   (aucune ligne router.* trouvée)"
else
  echo " [!] Aucun fichier AI (src/api/ai.ts ou ai.ts) détecté."
fi

# ------------------------------------------------------------------
# 4) STATUT PM2
# ------------------------------------------------------------------
echo
echo "------------------------------------------------------------"
echo "[4] STATUT PM2"
echo "------------------------------------------------------------"
if command -v pm2 >/dev/null 2>&1; then
  pm2 list || echo " [!] Impossible de lister les process pm2."
else
  echo " [!] pm2 non installé ou non trouvé dans PATH."
fi

# ------------------------------------------------------------------
# 5) PORTS ECOUTÉS (3000, 8080, 8443)
# ------------------------------------------------------------------
echo
echo "------------------------------------------------------------"
echo "[5] PORTS ECOUTÉS (3000 = backend, 8080/8443 = Nginx)"
echo "------------------------------------------------------------"

if command -v ss >/dev/null 2>&1; then
  for PORT in 3000 8080 8443; do
    echo " - Port $PORT :"
    ss -ltnp | grep ":$PORT" || echo "   (rien à l'écoute sur $PORT)"
  done
else
  echo " [!] ss non disponible, skip check ports."
fi

# ------------------------------------------------------------------
# 6) TESTS HTTP/HTTPS DE BASE
# ------------------------------------------------------------------
echo
echo "------------------------------------------------------------"
echo "[6] TESTS HTTP / HTTPS DE BASE"
echo "------------------------------------------------------------"

echo " - Test HTTP direct backend : http://127.0.0.1:3000/health"
if curl -sS -m 3 "http://127.0.0.1:3000/health" ; then
  echo
else
  echo " [!] /health (port 3000) ne répond pas ou erreur."
fi
echo

echo " - Test HTTP via Nginx : http://127.0.0.1:8080/health"
if curl -sS -m 3 "http://127.0.0.1:8080/health" ; then
  echo
else
  echo " [!] /health (port 8080) ne répond pas ou erreur."
fi
echo

echo " - Test HTTPS via Nginx : https://127.0.0.1:8443/health"
if curl -sS -m 3 -k "https://127.0.0.1:8443/health" ; then
  echo
else
  echo " [!] /health (port 8443, HTTPS) ne répond pas ou erreur."
fi
echo

if [ -n "$API_KEY" ]; then
  echo " - Test /api/ai/status via HTTPS (clé API) :"
  if curl -sS -m 5 -k "https://127.0.0.1:8443/api/ai/status" \
      -H "x-api-key: $API_KEY" ; then
    echo
  else
    echo " [!] /api/ai/status ne répond pas correctement."
  fi
else
  echo " [!] Pas de API_KEY => skip test /api/ai/status."
fi

# ------------------------------------------------------------------
# 7) LEDGER ONCHAIN DEMO
# ------------------------------------------------------------------
echo
echo "------------------------------------------------------------"
echo "[7] LEDGER ONCHAIN DEMO (onchain_demo_ledger.json)"
echo "------------------------------------------------------------"

LEDGER_FILE="$BACKEND_DIR/onchain_demo_ledger.json"
if [ -f "$LEDGER_FILE" ]; then
  echo " - Fichier trouvé : $LEDGER_FILE"
  echo " - Contenu (limité aux premières lignes) :"
  sed -n '1,120p' "$LEDGER_FILE" | sed 's/^/ | /'
else
  echo " [!] Fichier onchain_demo_ledger.json introuvable."
fi

# ------------------------------------------------------------------
# 8) OMNIUTIL SELFCHECK (si présent)
# ------------------------------------------------------------------
echo
echo "------------------------------------------------------------"
echo "[8] OMNIUTIL SELFCHECK (optionnel)"
echo "------------------------------------------------------------"

cd "$BASE_DIR"
if [ -x "./omniutil_selfcheck.sh" ]; then
  echo " - Script omniutil_selfcheck.sh détecté."
  echo "   (Tu peux le lancer séparément si tu veux un stress test / rate limit.)"
  echo "   Exemple : ./omniutil_selfcheck.sh"
else
  echo " - Aucun omniutil_selfcheck.sh exécutable détecté."
fi

echo
echo "============================================================"
echo " OMNIUTIL DEEP STATUS – TERMINE"
echo "============================================================"
