#!/usr/bin/env bash
set -e

echo "🚀 OMNIUTIL — FULL AUTONOMOUS TERMUX BOOTSTRAP"
echo "================================================="

ROOT_DIR="$HOME/omniutil"

echo "🔧 [1/6] System packages..."
pkg update -y || true
pkg upgrade -y || true
pkg install -y git clang cmake python nodejs openssl curl wget jq || true
echo "✅ System packages installed"

echo "🔧 [2/6] Configuring npm-global..."
mkdir -p ~/.npm-global
npm config set prefix "$HOME/.npm-global"

# Inject PATH if not present
if ! grep -q "npm-global/bin" ~/.bashrc; then
  echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> ~/.bashrc
fi
export PATH=$HOME/.npm-global/bin:$PATH
echo "✅ npm-global configured"

echo "🔧 [3/6] Installing global JS tools..."
npm install -g pnpm ts-node typescript pm2 vercel hardhat || true

echo "✅ Global JS tools installed:"
echo "- pnpm: $(which pnpm)"
echo "- ts-node: $(which ts-node)"
echo "- typescript: $(which tsc)"
echo "- pm2: $(which pm2)"
echo "- vercel: $(which vercel)"
echo "- hardhat: $(which hardhat)"

echo "🔧 [4/6] Ensuring omniutil directory..."
cd "$ROOT_DIR" || { echo "❌ Directory $ROOT_DIR not found!"; exit 1; }

echo "🔧 [5/6] Running omniutil.sh..."
chmod +x omniutil.sh scripts/*.sh
./omniutil.sh

echo "✅ omniutil.sh executed"

echo "🔧 [6/6] Final verification..."
echo "Node: $(node -v)"
echo "npm: $(npm -v)"
echo "pnpm: $(pnpm -v)"
echo "Hardhat: $(hardhat --version)"
echo "PM2: $(pm2 -v)"
echo "Vercel: $(vercel --version)"

echo "================================================="
echo "🏁 OMNIUTIL SYSTEM BOOTSTRAPPED SUCCESSFULLY"
