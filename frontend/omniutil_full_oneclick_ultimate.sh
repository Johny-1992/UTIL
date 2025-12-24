#!/bin/bash
# omniutil_full_oneclick_ultimate_fixed.sh
# 🚀 One-Click Ultimate OMNIUTIL Launcher (Backend + Frontend)

set -e

# Chemins
BACKEND_DIR="/root/omniutil/backend"
FRONTEND_DIR="/root/omniutil/frontend"
FRONTEND_PORT=8080
BACKEND_PORT=3000

echo "📌 Chemins :"
echo "Backend : $BACKEND_DIR"
echo "Frontend : $FRONTEND_DIR"

# 1️⃣ Compilation TypeScript backend
echo "📦 1/6 : Compilation TypeScript backend..."
cd "$BACKEND_DIR"
npx tsc
echo "✅ Compilation terminée."

# 2️⃣ Redémarrage backend PM2
echo "🔄 2/6 : Redémarrage backend PM2..."
pm2 restart omniutil-api --update-env || pm2 start dist/index.js --name omniutil-api
pm2 save
echo "✅ Backend relancé."

# 3️⃣ Lancement frontend avec serve (corrige l'erreur root)
echo "🌐 3/6 : Lancement frontend sur http://127.0.0.1:$FRONTEND_PORT..."
cd "$FRONTEND_DIR"

# Installer serve si nécessaire
if ! command -v serve >/dev/null 2>&1; then
    npm install -g serve
fi

# Lancer le frontend sur localhost uniquement pour éviter l'erreur SystemError 13
serve -s build -l 127.0.0.1:$FRONTEND_PORT &
FRONTEND_PID=$!
echo "✅ Frontend lancé (PID: $FRONTEND_PID)."

# 4️⃣ Vérification backend
echo "🔍 4/6 : Vérification backend..."
curl -s http://127.0.0.1:$BACKEND_PORT/health | grep ok >/dev/null && echo "✅ Backend répond sur http://127.0.0.1:$BACKEND_PORT/health" || echo "❌ Backend KO"

# 5️⃣ Détection endpoints backend
echo "🔍 5/6 : Détection endpoints backend..."
node "$BACKEND_DIR/list_routes.js" || echo "⚠️ Impossible de détecter les routes automatiquement"

# 6️⃣ Test automatique endpoints
echo "🧪 6/6 : Test automatique endpoints..."
node "$BACKEND_DIR/test_all_endpoints_auto.js" || echo "⚠️ Tests endpoints échoués"

echo "🎉 OMNIUTIL FULL ONE-CLICK FIXED TERMINÉ !"
echo "Frontend : http://127.0.0.1:$FRONTEND_PORT"
echo "Backend  : http://127.0.0.1:$BACKEND_PORT/health"
