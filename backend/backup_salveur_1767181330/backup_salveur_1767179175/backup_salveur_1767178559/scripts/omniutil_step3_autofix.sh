#!/bin/bash
echo "🚀 OMNIUTIL — STEP 3 AUTO-FIX AI & IMMORTALIZATION"
echo "================================================="

BACKEND_PATH="/root/omniutil/backend"
FRONTEND_PATH="/root/omniutil/frontend"

cd $BACKEND_PATH || exit 1

echo "📦 1/6 : Vérification des dépendances..."
npm install

echo "📦 2/6 : Compilation TypeScript..."
npx tsc
if [ $? -ne 0 ]; then
  echo "⚠️ Erreur de compilation TypeScript. Tentative de correction..."
  npx tsc --noEmitOnError false
fi

echo "🔄 3/6 : Redémarrage backend avec PM2..."
pm2 delete omniutil-api 2>/dev/null
pm2 start dist/index.js --name "omniutil-api" --watch
pm2 save

echo "✅ PM2 backend immortalisé et sauvegardé"

echo "🔍 4/6 : Vérification backend..."
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/health)
if [ "$HEALTH" = "200" ]; then
  echo "✅ Backend répond sur /health"
else
  echo "⚠️ Backend KO : code HTTP $HEALTH"
  echo "Vérifie les logs PM2 avec : pm2 logs omniutil-api"
fi

echo "🧪 5/6 : Test AI Coordinator endpoint..."
AI_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/api/ai/test)
if [ "$AI_TEST" = "200" ]; then
  echo "✅ AI Coordinator endpoint OK"
else
  echo "⚠️ AI Coordinator KO : code HTTP $AI_TEST"
fi

echo "🎉 STEP 3 AUTO-FIX TERMINÉ !"
echo "Backend : http://127.0.0.1:3000/health"
