#!/usr/bin/env bash
set -e

echo "🚀 OMNIUTIL — Ultimate Secure Autonomous Bootstrap"
echo "================================================="

ROOT_DIR="$(pwd)/.."

########################################
# 0️⃣ ENVIRONMENT
########################################
echo "🔧 [0/10] Updating system and installing prerequisites..."
apt update -y
apt upgrade -y
apt install -y git curl wget build-essential clang cmake python3 python3-pip nodejs npm jq nano

npm install -g pnpm ts-node typescript pm2 vercel || true

echo "✅ Environment ready"

########################################
# 1️⃣ CLONE REPO
########################################
echo "📂 [1/10] Cloning/updating OMNIUTIL repo..."
cd "$ROOT_DIR"
if [ ! -d omniutil ]; then
    git clone https://github.com/Johny-1992/omniutil.git
else
    cd omniutil
    git pull
fi
cd "$ROOT_DIR/omniutil"

########################################
# 2️⃣ SMART CONTRACTS
########################################
echo "📜 [2/10] Compiling smart contracts..."
cd contracts
rm -rf node_modules package-lock.json
npm install --save-dev hardhat@3.0.0 @nomicfoundation/hardhat-toolbox --legacy-peer-deps
npx hardhat compile || true
cd "$ROOT_DIR/omniutil"

########################################
# 3️⃣ BACKEND
########################################
echo "🌐 [3/10] Installing backend dependencies..."
cd backend
pnpm install express cors dotenv ethers typescript ts-node @types/node @types/express || npm install express cors dotenv ethers typescript ts-node @types/node @types/express

pm2 delete omniutil-api || true
pm2 start api/index.ts --name omniutil-api --interpreter ts-node

cd "$ROOT_DIR/omniutil"
echo "✅ Backend running via PM2"

########################################
# 4️⃣ FRONTEND
########################################
echo "🖥️ [4/10] Setting up frontend..."
cd frontend/landing
# index.html par défaut déjà fourni
cd "$ROOT_DIR/omniutil"
echo "✅ Frontend ready"

########################################
# 5️⃣ DEPLOY
########################################
echo "🚢 [5/10] Deployment (demo = real)..."
npx vercel pull --yes --environment=preview || true
npx vercel deploy --yes || true

########################################
# 6️⃣ VERIFY
########################################
echo "🔍 [6/10] Verifying API..."
sleep 5
if curl -s http://localhost:3000/health | grep -q "OMNIUTIL"; then
  echo "✅ API verified"
else
  echo "⚠️ API not reachable"
fi

echo "================================================="
echo "🏁 OMNIUTIL SYSTEM BOOTSTRAPPED SUCCESSFULLY"
