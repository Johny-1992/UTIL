#!/bin/bash
echo "🚀 OMNIUTIL FULL ONE-CLICK ULTIMATE FIXED LAUNCHER"
echo "📍 Initialisation..."

BACKEND_DIR="/root/omniutil/backend"
FRONTEND_DIR="/root/omniutil/frontend"
FRONTEND_PORT=8080
BACKEND_PORT=3000

echo "📌 Chemins détectés :"
echo "Backend : $BACKEND_DIR"
echo "Frontend : $FRONTEND_DIR"
echo ""

# Étape 1 : Compilation backend
echo "📦 1/6 : Compilation TypeScript backend..."
cd "$BACKEND_DIR" || { echo "❌ Erreur : dossier backend introuvable"; exit 1; }
npx tsc
echo "✅ Compilation terminée."

# Étape 2 : Redémarrage backend avec PM2
echo "🔄 2/6 : Redémarrage backend PM2..."
pm2 restart omniutil-api || pm2 start dist/index.js --name omniutil-api
pm2 save
echo "✅ Backend relancé."

# Étape 3 : Lancement frontend sécurisé
echo "🌐 3/6 : Lancement frontend sur http://127.0.0.1:$FRONTEND_PORT..."
cd "$FRONTEND_DIR" || { echo "❌ Erreur : dossier frontend introuvable"; exit 1; }

# Correction du bug Node uv_interface_addresses
unset NODE_OPTIONS
kill -9 $(lsof -t -i:$FRONTEND_PORT) >/dev/null 2>&1 || true

# Lancer le serveur frontend
npx serve -s . -l $FRONTEND_PORT --no-request-logging &
FRONT_PID=$!
sleep 3
echo "✅ Frontend lancé (PID $FRONT_PID)."

# Étape 4 : Vérification backend
echo "🔍 4/6 : Vérification backend..."
if curl -s "http://127.0.0.1:$BACKEND_PORT/health" | grep -q "ok"; then
    echo "✅ Backend répond sur http://127.0.0.1:$BACKEND_PORT/health"
else
    echo "⚠️  Backend ne répond pas encore."
fi

# Étape 5 : Détection endpoints
echo "🔍 5/6 : Détection des endpoints backend..."
ENDPOINTS=$(grep -R "router\." "$BACKEND_DIR/src/api" 2>/dev/null | awk '{print $2}' | sort | uniq)
echo "Endpoints détectés : $ENDPOINTS"

# Étape 6 : Test automatique (si script dispo)
if [ -f "$BACKEND_DIR/test_endpoints_dynamic.js" ]; then
    echo "🧪 6/6 : Test automatique endpoints..."
    node "$BACKEND_DIR/test_endpoints_dynamic.js"
else
    echo "ℹ️ Aucun test automatique trouvé."
fi

echo ""
echo "🎉 OMNIUTIL FULL ONE-CLICK FIXED TERMINÉ !"
echo "Frontend : http://127.0.0.1:$FRONTEND_PORT"
echo "Backend  : http://127.0.0.1:$BACKEND_PORT/health"
