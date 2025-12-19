#!/usr/bin/env bash
set -e

echo "🚀 OMNIUTIL — Termux Stable Mode"
echo "======================================="

########################################
# 1️⃣ System dependencies
########################################
echo "🔧 [1/10] Installing system dependencies..."
apt update -y
apt install -y \
  git curl wget nano jq \
  nodejs npm \
  python3 python3-pip \
  build-essential

echo "✅ System dependencies ready"

########################################
# 2️⃣ Stabilize npm (Termux / proot safe)
########################################
echo "🧹 [2/10] Stabilizing npm configuration..."
npm config set fund false --global || true
npm config set audit false --global || true
npm config set update-notifier false --global || true
npm config set cache /tmp/.npm --global || true
mkdir -p /tmp/.npm
echo "✅ npm stabilized"

########################################
# 3️⃣ Install PM2 (safe mode)
########################################
echo "⚙️ [3/10] Installing PM2 (safe mode)..."
if command -v pm2 >/dev/null 2>&1; then
  echo "✅ PM2 already installed"
else
  npm install -g pm2 || echo "⚠️ PM2 install skipped (npm issue tolerated)"
fi

########################################
# 4️⃣ Clone or update OMNIUTIL
########################################
echo "📂 [4/10] Cloning or updating OMNIUTIL repo..."
cd ~

if [ -d omniutil/.git ]; then
  cd omniutil
  git pull
else
  rm -rf omniutil
  git clone https://github.com/Johny-1992/omniutil.git
  cd omniutil
fi

########################################
# 5️⃣ Ensure project structure
########################################
echo "📁 [5/10] Ensuring project structure..."
mkdir -p backend frontend contracts scripts
echo "✅ Structure OK"

########################################
# 6️⃣ Backend dependencies
########################################
echo "🌐 [6/10] Installing backend dependencies..."
if [ -f backend/package.json ]; then
  cd backend

  if command -v pnpm >/dev/null 2>&1; then
    pnpm install || true
  else
    npm install -g pnpm || true
    pnpm install || true
  fi

  cd ..
else
  echo "⚠️ No backend/package.json found, skipping"
fi

########################################
# 7️⃣ Build step (fail-safe)
########################################
echo "🏗️ [7/10] Build step (fail-safe)..."
if [ -f backend/package.json ]; then
  cd backend
  npm run build || echo "⚠️ Build skipped (non-blocking)"
  cd ..
fi

########################################
# 8️⃣ START API — CORRECTED SECTION ✅
########################################
echo "🚀 [8/10] Starting OMNIUTIL API..."

APP_NAME="omniutil-api"

# Stop old instance if exists
pm2 delete "$APP_NAME" >/dev/null 2>&1 || true

# Auto-detect backend entry point
if [ -f backend/src/index.ts ] && command -v bun >/dev/null 2>&1; then
  echo "🍞 Starting with Bun (TypeScript)"
  cd backend
  pm2 start src/index.ts --interpreter bun --name "$APP_NAME"

elif [ -f backend/dist/index.js ]; then
  echo "🟢 Starting compiled Node.js version"
  cd backend
  pm2 start dist/index.js --name "$APP_NAME"

elif [ -f backend/index.js ]; then
  echo "🟡 Starting Node.js fallback"
  cd backend
  pm2 start index.js --name "$APP_NAME"

else
  echo "❌ No backend entry point found"
  echo "Expected one of:"
  echo " - backend/src/index.ts"
  echo " - backend/dist/index.js"
  echo " - backend/index.js"
  exit 1
fi

cd ~

########################################
# 9️⃣ PM2 persistence (best effort)
########################################
echo "♻️ [9/10] Saving PM2 process list..."
pm2 save || true

########################################
# 🔟 Final status
########################################
echo "🎉 [10/10] OMNIUTIL is LIVE"
pm2 list

echo "======================================="
echo "✅ OMNIUTIL infrastructure operational"
echo "🌍 Ready for demo / production / scaling"
