#!/bin/bash
set -e

BACKEND_DIR="/root/omniutil/backend"
FRONTEND_DIR="/root/omniutil/frontend/landing"

echo "🚀 ONE-CLICK FULL OMNIUTIL LAUNCHER"

# 1️⃣ Compilation TypeScript
echo "📦 1/6 : Compilation TypeScript..."
cd $BACKEND_DIR
npx tsc
echo "✅ Compilation terminée."

# 2️⃣ Relance PM2 backend
echo "🔄 2/6 : Redémarrage backend PM2..."
pm2 restart omniutil-api --update-env || pm2 start dist/index.js --name omniutil-api
pm2 save
echo "✅ Backend relancé."

# 3️⃣ Lancer le frontend
echo "🌐 3/6 : Lancement frontend sur http://0.0.0.0:8080..."
cd $FRONTEND_DIR
nohup python3 -m http.server 8080 > frontend.log 2>&1 &
echo "✅ Frontend lancé."

# 4️⃣ Détection des endpoints
echo "🔍 4/6 : Détection des endpoints..."
ENDPOINTS=$(node -e "
const app = require('$BACKEND_DIR/dist/index.js').default || require('$BACKEND_DIR/dist/index.js');
if(!app._router){ console.log('Aucune route détectée'); process.exit(0);}
const routes = app._router.stack.filter(r => r.route).map(r => ({
    path: r.route.path,
    methods: Object.keys(r.route.methods)
}));
console.log(JSON.stringify(routes));
")

echo "Endpoints détectés : $ENDPOINTS"

# 5️⃣ Test automatique des endpoints
echo "🧪 5/6 : Test automatique des endpoints..."
for row in $(echo "$ENDPOINTS" | jq -c '.[]'); do
    PATH=$(echo $row | jq -r '.path')
    METHODS=$(echo $row | jq -r '.methods[]')
    if [ "$METHODS" == "get" ]; then
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000$PATH)
        echo "GET $PATH -> Status: $STATUS"
    elif [ "$METHODS" == "post" ]; then
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://127.0.0.1:3000$PATH -H "Content-Type: application/json" -d '{"test":"ok"}')
        echo "POST $PATH -> Status: $STATUS"
    fi
done

echo "🎉 ONE-CLICK FULL OMNIUTIL TERMINÉ !"
echo "Frontend: http://127.0.0.1:8080"
echo "Backend: http://127.0.0.1:3000/health"
