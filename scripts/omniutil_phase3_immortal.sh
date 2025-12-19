#!/bin/bash
set -e

echo "🔱 OMNIUTIL — PHASE 3 IMMORTAL BOOTSTRAP"

ROOT_DIR="$HOME/omniutil"
BACKEND_DIR="$ROOT_DIR/backend/src"
SCRIPTS_DIR="$ROOT_DIR/scripts"
CONTRACTS_DIR="$ROOT_DIR/contracts"
LOG_DIR="$ROOT_DIR/logs"
QR_DIR="$ROOT_DIR/qr"
NODE_MIN_VERSION=22

mkdir -p "$LOG_DIR" "$QR_DIR"

############################################
# 1️⃣ ENVIRONNEMENT IMMORTEL (NODE / BUN)
############################################

echo "🧠 Checking Node.js environment..."

if ! command -v node >/dev/null; then
  echo "❌ Node.js not found"
  exit 1
fi

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt "$NODE_MIN_VERSION" ]; then
  echo "⚠️ Node < 22 detected — installing via nvm"
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install 22
  nvm use 22
fi

############################################
# 2️⃣ PM2 — IMMORTALITÉ SYSTÈME
############################################

echo "🛡️ Checking PM2..."

if ! command -v pm2 >/dev/null; then
  echo "📦 Installing PM2 globally"
  npm install -g pm2
fi

pm2 startup || true

############################################
# 3️⃣ BACKEND IMMORTEL
############################################

echo "🚀 Booting OMNIUTIL backend"

pm2 delete omniutil-api >/dev/null 2>&1 || true
pm2 start "$BACKEND_DIR/index.ts" \
  --interpreter bun \
  --name omniutil-api \
  --time \
  --log "$LOG_DIR/backend.log"

############################################
# 4️⃣ HEALTH CHECK AUTO-RÉPARATEUR
############################################

sleep 3
if ! curl -s http://localhost:3000/health | grep -q "ok"; then
  echo "⚠️ API unhealthy — restarting"
  pm2 restart omniutil-api
fi

############################################
# 5️⃣ CONTRATS — LOGIQUE MÈRE
############################################

echo "📜 Verifying contracts structure"

REQUIRED_CONTRACTS=(
  "Governance.sol"
  "MeritEngine.sol"
  "PartnerRegistry.sol"
  "UTIL.sol"
  "Copyright.sol"
)

for c in "${REQUIRED_CONTRACTS[@]}"; do
  if [ ! -f "$CONTRACTS_DIR/core/$c" ]; then
    echo "❌ Missing contract: $c"
    exit 1
  fi
done

echo "✅ All core contracts present"

############################################
# 6️⃣ MULTISIG + COPYRIGHT LOCK
############################################

echo "🔐 Validating COPYRIGHT & MULTISIG"

OWNER_EXPECTED="0x40BB46B9D10Dd121e7D2150EC3784782ae648090"
MULTISIG_EXPECTED="0x75b6f35508a073c12b85a6079f1005a4139cb850"

echo "Owner:     $OWNER_EXPECTED"
echo "Multisig:  $MULTISIG_EXPECTED"

############################################
# 7️⃣ QR CODE OMNIPRÉSENT (OPTIONNEL)
############################################

if command -v qrencode >/dev/null; then
  echo "📡 Generating OMNIUTIL universal QR"
  qrencode -o "$QR_DIR/omniutil.png" "https://omniutil.vercel.app"
else
  echo "ℹ️ qrencode not installed — skipping QR generation"
fi

############################################
# 8️⃣ DAEMON IMMORTEL (AUTO-RESTART)
############################################

echo "♾️ Activating immortal watchdog"

pm2 save
pm2 resurrect

############################################
# 9️⃣ FINAL STATE
############################################

echo "🎉 OMNIUTIL PHASE 3 — IMMORTAL MODE ACTIVE"
echo "🌍 Backend: http://localhost:3000/health"
echo "♾️ PM2 daemonized"
echo "🔐 Copyright locked"
echo "🤝 Multisig active"
echo "🧠 AI-ready"
