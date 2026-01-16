#!/bin/bash
# 🚀 Omniutil STEP 3 SUPERFIX - AI & IMMORTALIZATION

echo "🚀 OMNIUTIL — STEP 3 SUPERFIX: AI & IMMORTALIZATION"
echo "================================================="

BACKEND_DIR="/root/omniutil/backend"
FRONTEND_DIR="/root/omniutil/frontend"
API_NAME="omniutil-api"

cd $BACKEND_DIR || { echo "❌ Backend directory not found"; exit 1; }

echo "📦 1/6 : Vérification et installation des dépendances..."
npm install
npm install --save-dev @types/node
npm install qrcode
npm install --save-dev @types/qrcode

echo "📦 2/6 : Compilation TypeScript..."
npx tsc || { echo "❌ Compilation failed"; exit 1; }

# Vérifier si index.js existe
if [ ! -f "$BACKEND_DIR/dist/index.js" ]; then
    echo "❌ index.js not found in dist/ folder, build failed."
    exit 1
fi

echo "🔄 3/6 : Redémarrage backend avec PM2..."
pm2 delete $API_NAME >/dev/null 2>&1
pm2 start dist/index.js --name $API_NAME
pm2 save

echo "🌐 4/6 : Vérification backend (/health)..."
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/health)
if [ "$HEALTH_STATUS" == "200" ]; then
    echo "✅ Backend OK"
else
    echo "⚠️ Backend KO (HTTP $HEALTH_STATUS)"
    echo "Vérifie les logs : pm2 logs $API_NAME"
fi

echo "🧪 5/6 : Test AI Coordinator endpoint..."
AI_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/api/ai/test)
if [ "$AI_STATUS" == "200" ]; then
    echo "✅ AI Coordinator OK"
else
    echo "⚠️ AI Coordinator KO (HTTP $AI_STATUS)"
    echo "Vérifie les logs : pm2 logs $API_NAME"
fi

echo "📊 6/6 : Rapport final"
echo "Frontend : $FRONTEND_DIR"
echo "Backend  : http://127.0.0.1:3000/health"
echo "✅ STEP 3 SUPERFIX TERMINÉ !"
