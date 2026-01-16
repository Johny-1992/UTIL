#!/bin/bash
set -e

echo "==============================================="
echo "🔒 OMNIUTIL — STEP 3 LOCKED (STABLE)"
echo "==============================================="

cd /root/omniutil/backend

echo "📦 Vérification dépendances..."
npm install

echo "🛑 Nettoyage PM2..."
pm2 delete omniutil-api || true

echo "🚀 Démarrage API via ts-node (mode stable)..."
pm2 start src/index.ts \
  --name omniutil-api \
  --interpreter npx \
  --interpreter-args "ts-node"

pm2 save

echo "🌐 Test /health..."
sleep 2
curl -f http://127.0.0.1:3000/health && echo "✅ STEP 3 VALIDÉE À 100 %"

echo "==============================================="
echo "🎉 STEP 3 DÉFINITIVEMENT VERROUILLÉE"
echo "==============================================="
