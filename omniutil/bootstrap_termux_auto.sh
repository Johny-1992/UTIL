#!/usr/bin/env bash
set -e

echo "🚀 OMNIUTIL — FULL AUTONOMOUS TERMUX BOOTSTRAP"
echo "================================================="

ROOT_DIR="$HOME/omniutil"

# -------------------------------
# 1️⃣ SYSTEM PACKAGES
# -------------------------------
echo "🔧 [1/6] Installing system packages..."
pkg update -y || true
pkg upgrade -y || true
pkg install -y git clang cmake python nodejs openssl curl wget jq || true
echo "✅ System packages installed"

# -------------------------------
# 2️⃣ NPM-GLOBAL CONFIGURATION
# -------------------------------
echo "🔧 [2/6] Configuring npm-global..."
mkdir -p ~/.npm-global
npm config set prefix "$HOME/.npm-global"

# Ensure PATH is exported in current session and future sessions
if ! grep -q "npm-global/bin" ~/.bashrc; then
  echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> ~/.bashrc
fi
export PATH="$HOME/.npm-global/bin:$PATH"

# Verify npm-global path
echo "✅ npm-global path set: $PATH"

# -------------------------------
# 3️⃣ INSTALL GLOBAL JS TOOLS
# -------------------------------
echo "🔧 [3/6] Installing global JS tools (pnpm, hardhat, pm2, ts-node, typescript, vercel)..."

for tool in pnpm hardhat pm2 ts-node typescript vercel; do
  if ! command -v $tool &> /dev/null; then
    echo "Installing $tool..."
    npm install -g $tool || { echo "❌ Failed to install $tool"; exit 1; }
  else
    echo "$tool already installed"
  fi
done

echo "✅ Global tools installed:"
which pnpm
which hardhat
which pm2
which vercel

# -------------------------------
# 4️⃣ ENSURE OMNIUTIL DIRECTORY
# -------------------------------
echo "🔧 [4/6] Ensuring omniutil directory exists..."
if [ ! -d "$ROOT_DIR" ]; then
  echo "❌ Directory $ROOT_DIR not found!"
  exit 1
fi
cd "$ROOT_DIR"

# Make scripts executable
chmod +x omniutil.sh scripts/*.sh

# -------------------------------
# 5️⃣ RUN OMNIUTIL.SH
# -------------------------------
echo "🔧 [5/6] Running omniutil.sh..."
./omniutil.sh || { echo "❌ omniutil.sh failed"; exit 1; }

# -------------------------------
# 6️⃣ FINAL VERIFICATION
# -------------------------------
echo "🔧 [6/6] Final verification..."

echo "Node: $(node -v)"
echo "npm: $(npm -v)"
echo "pnpm: $(pnpm -v)"
echo "Hardhat: $(hardhat --version)"
echo "PM2: $(pm2 -v)"
echo "Vercel: $(vercel --version)"

echo "================================================="
echo "🏁 OMNIUTIL SYSTEM FULLY BOOTSTRAPPED & OPERATIONAL"
