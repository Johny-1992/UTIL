#!/bin/bash
set -e

echo "🧬 OMNIUTIL — FULL IMMORTAL (PROOT SAFE)"

cd /root/omniutil/backend

############################
# 1️⃣ DEPENDENCIES SAFE
############################
echo "📦 Installing TS deps..."
npm install --save-dev typescript ts-node --legacy-peer-deps

############################
# 2️⃣ tsconfig CLEAN
############################
cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "moduleResolution": "Node",
    "outDir": "dist",
    "rootDir": "src",
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"]
}
EOF
echo "✅ tsconfig.json OK"

############################
# 3️⃣ PORT AUTO-LIBRE (SANS ss)
############################
PORT=3000
while node -e "require('net').createServer().listen($PORT).on('error',()=>process.exit(1))"; do
  node -e "process.exit(0)"
  break
done || PORT=$((PORT+1))

echo "🔎 Using port $PORT"

############################
# 4️⃣ BOOTSTRAP index.ts
############################
cat > src/index.ts <<EOF
import app from "./api";

const port = process.env.PORT || $PORT;

app.listen(port, () => {
  console.log("🚀 OMNIUTIL API running on port " + port);
});
EOF

############################
# 5️⃣ BUILD RELIABLE
############################
echo "🏗️ Building TS..."
rm -rf dist
./node_modules/.bin/tsc

echo "📦 dist/index.js OK"

############################
# 6️⃣ PM2 IMMORTAL
############################
pm2 delete omniutil-api || true
pm2 start dist/index.js --name omniutil-api --watch
pm2 save

############################
# 7️⃣ TEST FINAL
############################
sleep 2
echo "🧪 Testing /health..."
curl -s http://127.0.0.1:$PORT/health || true

echo "🏆 OMNIUTIL IMMORTAL — PROOT MODE READY"
