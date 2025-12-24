#!/bin/bash
# OMNIUTIL One-Click Fix & Test
# =====================================
# But : Recompile backend, relance PM2, teste tous les endpoints

BASE_DIR="/root/omniutil/backend"
BASE_URL="http://127.0.0.1:3000"

cd "$BASE_DIR" || { echo "❌ Impossible d'entrer dans $BASE_DIR"; exit 1; }

echo "📦 1/5 : Nettoyage du dist et compilation TypeScript..."
rm -rf dist
npm install
npx tsc
if [ ! -f dist/index.js ]; then
    echo "❌ dist/index.js manquant après compilation !"
    exit 1
fi
echo "✅ dist/index.js présent"

echo "🔄 2/5 : Relance du backend via PM2..."
pm2 delete omniutil-api || true
pm2 start dist/index.js --name omniutil-api --watch
pm2 save

sleep 2

echo "🔍 3/5 : Test santé API..."
curl -s "$BASE_URL/health" | grep ok >/dev/null
if [ $? -eq 0 ]; then
    echo "✅ API répond sur $BASE_URL/health"
else
    echo "❌ API ne répond pas correctement sur $BASE_URL/health"
fi

echo "🛠 4/5 : Détection des endpoints disponibles dans dist/api..."
ROUTES=()
for f in dist/api/*.js; do
    route=$(basename "$f" .js)
    ROUTES+=("/api/$route")
done

if [ ${#ROUTES[@]} -eq 0 ]; then
    echo "⚠️  Aucun endpoint détecté dans dist/api"
else
    echo "✅ Endpoints détectés : ${ROUTES[*]}"
fi

echo "🧪 5/5 : Test de chaque endpoint..."
for r in "${ROUTES[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$r")
    if [ "$response" == "200" ]; then
        echo "✅ $r OK (GET)"
    else
        echo "❌ $r ne répond pas correctement (HTTP $response)"
    fi
done

echo "🎉 One-Click Fix & Test terminé !"
