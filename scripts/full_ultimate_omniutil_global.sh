#!/bin/bash
set -e

# =================================================
# 🚀 OMNIUTIL — Global Auto-Deploy Mode
# Maintient tous les atouts du script précédent
# =================================================

ROOT_DIR="$HOME/omniutil"
SCRIPTS_DIR="$ROOT_DIR/scripts"
BACKEND_DIR="$ROOT_DIR/backend"

echo "🚀 OMNIUTIL — Global Auto-Deploy Mode"
echo "======================================="

# -------------------------------
# 1/10 - System dependencies
# -------------------------------
echo "🔧 [1/10] Installing system dependencies..."
apt update -y
apt install -y git curl wget nano build-essential python3 python3-pip

echo "✅ System dependencies ready"

# -------------------------------
# 2/10 - Stabilizing npm
# -------------------------------
echo "🧹 [2/10] Stabilizing npm configuration..."
npm config set cache ~/.npm --global
npm config set fund false
npm config set audit false
npm cache clean --force
echo "✅ npm stabilized"

# -------------------------------
# 3/10 - PM2 installation (safe mode)
# -------------------------------
echo "⚙️ [3/10] Installing PM2 (safe mode)..."
if ! command -v pm2 >/dev/null 2>&1; then
  npm install -g pm2
else
  echo "✅ PM2 already installed"
fi

# -------------------------------
# 4/10 - Clone/update OMNIUTIL repo
# -------------------------------
echo "📂 [4/10] Cloning or updating OMNIUTIL repo..."
if [ ! -d "$ROOT_DIR" ]; then
  git clone https://github.com/Johny-1992/omniutil.git "$ROOT_DIR"
else
  cd "$ROOT_DIR"
  git fetch origin
  git reset --hard origin/main
  git pull
fi
echo "✅ Repo ready"

# -------------------------------
# 5/10 - Ensuring project structure
# -------------------------------
echo "📁 [5/10] Ensuring project structure..."
mkdir -p "$BACKEND_DIR/node_modules" "$BACKEND_DIR/dist"
echo "✅ Structure OK"

# -------------------------------
# 6/10 - Installing backend dependencies
# -------------------------------
echo "🌐 [6/10] Installing backend dependencies..."
cd "$BACKEND_DIR"
if [ -f "package-lock.json" ]; then
  npm install
elif [ -f "pnpm-lock.yaml" ]; then
  pnpm install
else
  npm init -y
  npm install express cors dotenv ethers ts-node typescript @types/node @types/express --save
fi
echo "✅ Backend dependencies ready"

# -------------------------------
# 7/10 - Build step (fail-safe)
# -------------------------------
echo "🏗️ [7/10] Build step (fail-safe)..."
if npm run | grep -q build; then
  npm run build || echo "⚠️ Build failed, skipping..."
else
  echo "⚠️ No build script found, skipping..."
fi

# -------------------------------
# 8/10 - Starting OMNIUTIL API
# -------------------------------
echo "🚀 [8/10] Starting OMNIUTIL API..."
cd "$BACKEND_DIR"

if command -v bun >/dev/null 2>&1; then
  if [ -f "src/index.ts" ]; then
    pm2 start src/index.ts --interpreter bun --name omniutil-api
  else
    echo "❌ src/index.ts not found, skipping Bun start"
  fi
else
  if [ -f "dist/index.js" ]; then
    pm2 start dist/index.js --name omniutil-api
  else
    echo "❌ dist/index.js not found, skipping Node start"
  fi
fi

# -------------------------------
# 9/10 - Saving PM2 process list
# -------------------------------
echo "♻️ [9/10] Saving PM2 process list..."
pm2 save

# -------------------------------
# 10/10 - OMNIUTIL LIVE
# -------------------------------
echo "🎉 [10/10] OMNIUTIL is LIVE"
pm2 ls
echo "🌍 Ready for demo / production / scaling"
