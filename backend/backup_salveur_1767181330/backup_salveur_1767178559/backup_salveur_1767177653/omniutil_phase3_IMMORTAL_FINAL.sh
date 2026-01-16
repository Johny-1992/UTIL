#!/bin/bash
set -e

echo "🧬 OMNIUTIL — PHASE 3 IMMORTAL FINAL"

cd /root/omniutil/backend

# 1️⃣ Nettoyage PM2
pm2 delete omniutil-api || true
pm2 flush || true

# 2️⃣ Dépendances TS
npm install --save-dev typescript ts-node --legacy-peer-deps

# 3️⃣ tsconfig SIMPLE & STABLE
cat > tsconfig.json <<'TS'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "moduleResolution": "Node",
    "outDir": "dist",
    "rootDir": ".",
    "esModuleInterop": true,
    "strict": false,
    "skipLibCheck": true
  },
  "include": ["src/**/*", "api/**/*", "services/**/*"],
  "exclude": ["node_modules", "dist"]
}
TS

echo "✅ tsconfig.json OK"

# 4️⃣ Build clean
rm -rf dist
npx tsc

echo "🏗️ Build OK"

# 5️⃣ PM2 sur JS compilé (PAS TS)
pm2 start dist/index.js --name omniutil-api
pm2 save

echo "🚀 PM2 started on dist/index.js"

# 6️⃣ Test API
sleep 2
echo "🧪 Testing /health..."
curl -s http://127.0.0.1:3000/health || {
  echo "❌ API NOT RESPONDING"
  pm2 logs omniutil-api --lines 50
  exit 1
}

echo "🏆 OMNIUTIL PHASE 3 — IMMORTAL SUCCESS"
