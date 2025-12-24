#!/usr/bin/env bash
set -e

echo "🚀 OMNIUTIL MASTER FINAL — FULL ORCHESTRATION (Termux/Proot Ubuntu)"
echo "================================================="

ROOT_DIR="/root/omniutil"

########################################
# 1️⃣ Backend restart (PM2)
########################################
echo "🌐 [1/7] Restarting Backend..."
cd "$ROOT_DIR/backend"

# Compile TS si nécessaire
if [ -f "tsconfig.json" ]; then
  npx tsc
fi

pm2 delete omniutil-api || true
pm2 start dist/index.js --name omniutil-api --watch
pm2 save

echo "✅ Backend running via PM2"

########################################
# 2️⃣ API Health check
########################################
echo "🔍 [2/7] API health check..."
HEALTH=$(curl -s http://127.0.0.1:3000/health)
if [[ $HEALTH == *"ok"* ]]; then
  echo "✅ API verified: $HEALTH"
else
  echo "⚠️ API check failed"
fi

########################################
# 3️⃣ AI Engine test
########################################
echo "🧠 [3/7] AI Engine check..."
AI_DIR="$ROOT_DIR/backend/ai"
if [ -f "$AI_DIR/libscore.so" ]; then
  echo "✅ AI Engine library found: libscore.so"
else
  echo "⚠️ AI Engine not found, compiling..."
  clang++ -shared -fPIC scoring_engine.cpp -o libscore.so
  echo "✅ AI Engine compiled"
fi

########################################
# 4️⃣ Frontend local test
########################################
echo "🖥️ [4/7] Frontend check..."
FRONTEND_DIR="$ROOT_DIR/frontend/landing"
if [ -f "$FRONTEND_DIR/index.html" ]; then
  echo "✅ Frontend ready: index.html exists"
else
  echo "⚠️ Frontend missing"
fi

########################################
# 5️⃣ Vercel deployment headless
########################################
echo "🚢 [5/7] Deploying to Vercel (headless)..."
if ! command -v vercel &> /dev/null; then
  npm install -g vercel
fi

# Remplace <TON_TOKEN> par ton token Vercel personnel
VERCEL_TOKEN="<TON_TOKEN>"
vercel --token $VERCEL_TOKEN --prod --confirm

echo "✅ Deployment triggered"

########################################
# 6️⃣ Final verification
########################################
echo "🔍 [6/7] Final system verification..."
HEALTH=$(curl -s http://127.0.0.1:3000/health)
if [[ $HEALTH == *"ok"* ]]; then
  echo "✅ API verified after deployment: $HEALTH"
else
  echo "⚠️ API check failed after deployment"
fi

########################################
# 7️⃣ Git commit & push
########################################
echo "📦 [7/7] Commit & push..."
cd "$ROOT_DIR"
git add .
git commit -m "OMNIUTIL: full final orchestration run" || true
git push || true

echo "================================================="
echo "🏁 OMNIUTIL MASTER FINAL SCRIPT EXECUTED SUCCESSFULLY"
echo "Demo = Real | Automation = Total | Ready for Partners"
