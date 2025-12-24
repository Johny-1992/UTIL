#!/bin/bash
# omniutil_full_oneclick_portable.sh
# 🚀 One-Click Ultimate OMNIUTIL Portable Launcher

set -e

# ------------------------------
# 1️⃣ Détection automatique des chemins
# ------------------------------
ROOT_DIR="$(pwd)"
echo "📌 Répertoire racine détecté : $ROOT_DIR"

BACKEND_DIR=$(find "$ROOT_DIR" -type d -name "backend" | head -n1)
FRONTEND_DIR=$(find "$ROOT_DIR" -type d -name "frontend" | head -n1)

if [[ -z "$BACKEND_DIR" || -z "$FRONTEND_DIR" ]]; then
    echo "❌ Impossible de détecter backend ou frontend !"
    exit 1
fi

BACKEND_DIST="$BACKEND_DIR/dist"
FRONTEND_BUILD="$FRONTEND_DIR/build"
BACKEND_PORT=3000
FRONTEND_PORT=8080

echo "Backend détecté : $BACKEND_DIR"
echo "Frontend détecté : $FRONTEND_DIR"

# ------------------------------
# 2️⃣ Compilation TypeScript backend
# ------------------------------
echo "📦 1/6 : Compilation TypeScript backend..."
cd "$BACKEND_DIR"
if [ -f tsconfig.json ]; then
    npx tsc
    echo "✅ Compilation terminée."
else
    echo "⚠️ Pas de tsconfig.json, compilation ignorée."
fi

# ------------------------------
# 3️⃣ Redémarrage backend PM2
# ------------------------------
echo "🔄 2/6 : Redémarrage backend PM2..."
if pm2 list | grep -q omniutil-api; then
    pm2 restart omniutil-api --update-env
else
    pm2 start "$BACKEND_DIST/index.js" --name omniutil-api
fi
pm2 save
echo "✅ Backend relancé."

# ------------------------------
# 4️⃣ Lancement frontend
# ------------------------------
echo "🌐 3/6 : Lancement frontend sur http://127.0.0.1:$FRONTEND_PORT..."
cd "$FRONTEND_DIR"

# Installer serve si nécessaire
if ! command -v serve >/dev/null 2>&1; then
    npm install -g serve
fi

if [ -d "$FRONTEND_BUILD" ]; then
    # Lancer frontend sur localhost pour éviter SystemError uv_interface_addresses
    serve -s "$FRONTEND_BUILD" -l 127.0.0.1:$FRONTEND_PORT &
    FRONTEND_PID=$!
    echo "✅ Frontend lancé (PID: $FRONTEND_PID)."
else
    echo "⚠️ Dossier build introuvable dans frontend, frontend non lancé."
fi

# ------------------------------
# 5️⃣ Vérification backend
# ------------------------------
echo "🔍 4/6 : Vérification backend..."
curl -s http://127.0.0.1:$BACKEND_PORT/health | grep ok >/dev/null && echo "✅ Backend OK" || echo "❌ Backend KO"

# ------------------------------
# 6️⃣ Détection et test endpoints backend
# ------------------------------
echo "🔍 5/6 : Détection endpoints backend..."
if [ -f "$BACKEND_DIR/list_routes.js" ]; then
    node "$BACKEND_DIR/list_routes.js" || echo "⚠️ Impossible de détecter les routes automatiquement"
else
    echo "⚠️ list_routes.js introuvable, détection routes ignorée."
fi

echo "🧪 6/6 : Test automatique endpoints..."
if [ -f "$BACKEND_DIR/test_all_endpoints_auto.js" ]; then
    node "$BACKEND_DIR/test_all_endpoints_auto.js" || echo "⚠️ Tests endpoints échoués"
else
    echo "⚠️ test_all_endpoints_auto.js introuvable, tests endpoints ignorés."
fi

echo "🎉 OMNIUTIL FULL ONE-CLICK PORTABLE TERMINÉ !"
echo "Frontend : http://127.0.0.1:$FRONTEND_PORT"
echo "Backend  : http://127.0.0.1:$BACKEND_PORT/health"
