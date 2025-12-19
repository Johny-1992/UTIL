#!/usr/bin/env bash
set -e

echo "🔧 Installing global prerequisites for Termux..."

pkg update -y
pkg upgrade -y
pkg install -y nodejs git clang cmake python openssl curl wget jq

# Fix npm global path for Termux
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# Inject PATH for this session
export PATH=$HOME/.npm-global/bin:$PATH

# Optional: add to bashrc for future sessions
if ! grep -q "npm-global/bin" ~/.bashrc; then
  echo 'export PATH=$HOME/.npm-global/bin:$PATH' >> ~/.bashrc
fi

# Install global JS tools
npm install -g pnpm hardhat pm2 ts-node typescript vercel

echo "✅ Global tools installed:"
which pnpm
which hardhat
which pm2
which vercel
