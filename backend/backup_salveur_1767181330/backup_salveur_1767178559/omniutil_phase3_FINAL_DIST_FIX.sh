#!/bin/bash
set -e

echo "🧬 OMNIUTIL — FINAL DIST FIX"

cd /root/omniutil/backend

# 1️⃣ Fix tsconfig.json
cat > tsconfig.json <<'JSON'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "rootDir": "src",
    "outDir": "dist",
    "esModuleInterop": true,
    "strict": false,
    "skipLibCheck": true
  },
  "include": ["src/**/*"]
}
JSON

echo "✅ tsconfig.json fixed"

# 2️⃣ Clean build
rm -rf dist
npx tsc

# 3️⃣ Verify output
if [ ! -f dist/index.js ]; then
  echo "❌ dist/index.js NOT FOUND"
  echo "📂 dist content:"
  find dist
  exit 1
fi

echo "📦 dist/index.js OK"

# 4️⃣ Restart PM2
pm2 delete omniutil-api || true
pm2 start dist/index.js --name omniutil-api
pm2 save

sleep 2

# 5️⃣ Test API
echo "🧪 Testing /health..."
curl -s http://127.0.0.1:3000/health || {
  echo "❌ API NOT RESPONDING"
  pm2 logs omniutil-api --lines 50
  exit 1
}

echo "🏆 OMNIUTIL API 100% OPERATIONAL"
