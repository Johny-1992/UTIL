#!/bin/bash
# 🚀 OMNIUTIL FULL ONE-CLICK ULTIMATE LAUNCHER

# --- CONFIG ---
BACKEND_PATH="/root/omniutil/backend"
FRONTEND_PATH="/root/omniutil/frontend"   # <FRONTEND_PORT=8080
BACKEND_HEALTH="http://127.0.0.1:3000/health"

echo "📌 Chemins :"
echo "Backend : $BACKEND_PATH"
echo "Frontend : $FRONTEND_PATH"

# --- 1️⃣ Compilation TypeScript backend ---
echo "📦 1/6 : Compilation TypeScript backend..."
cd "$BACKEND_PATH" || exit
npx tsc
if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la compilation TypeScript"
    exit 1
fi
echo "✅ Compilation terminée."

# --- 2️⃣ Redémarrage backend PM2 ---
echo "🔄 2/6 : Redémarrage backend PM2..."
pm2 restart omniutil-api --update-env || pm2 start dist/index.js --name omniutil-api
pm2 save
echo "✅ Backend relancé."

# --- 3️⃣ Lancement frontend ---
echo "🌐 3/6 : Lancement frontend sur http://0.0.0.0:$FRONTEND_PORT..."
if [ -d "$FRONTEND_PATH" ]; then
    cd "$FRONTEND_PATH" || exit
    # Si c'est un build statique, utiliser serve
    if [ -f "package.json" ]; then
        npm start &
    else
        npx serve -s build -l $FRONTEND_PORT &
    fi
    echo "✅ Frontend lancé."
else
    echo "⚠️ Dossier frontend introuvable : $FRONTEND_PATH"
fi

# --- 4️⃣ Test santé backend ---
echo "🔍 4/6 : Vérification backend..."
curl -s "$BACKEND_HEALTH" | jq . >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Backend répond sur $BACKEND_HEALTH"
else
    echo "❌ Backend ne répond pas correctement"
fi

# --- 5️⃣ Détection endpoints backend ---
echo "🔍 5/6 : Détection endpoints backend..."
ENDPOINTS=$(node -e "
const app = require('$BACKEND_PATH/dist/index');
if (app && app._router) {
    console.log(JSON.stringify(
        app._router.stack.filter(r => r.route).map(r => ({
            path: r.route.path,
            methods: Object.keys(r.route.methods)
        }))
    ));
} else console.log('[]');
")
echo "Endpoints détectés : $ENDPOINTS"

# --- 6️⃣ Test automatique endpoints ---
echo "🧪 6/6 : Test automatique endpoints..."
for ep in $(echo "$ENDPOINTS" | jq -c '.[]'); do
    PATH=$(echo "$ep" | jq -r '.path')
    METHODS=$(echo "$ep" | jq -r '.methods[]')
    if [ "$METHODS" = "get" ]; then
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_HEALTH$PATH")
        echo "GET $PATH => $STATUS"
    elif [ "$METHODS" = "post" ]; then
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BACKEND_HEALTH$PATH" -H "Content-Type: application/json" -d '{"test":"ok"}')
        echo "POST $PATH => $STATUS"
    fi
done

echo "🎉 OMNIUTIL FULL ONE-CLICK TERMINÉ !"
echo "Frontend : http://127.0.0.1:$FRONTEND_PORT"
echo "Backend : $BACKEND_HEALTH"
