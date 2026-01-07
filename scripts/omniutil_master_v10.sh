#!/bin/bash
set -e

echo "🛡️ OMNIUTIL — SCRIPT MAÎTRE v10"
echo "=============================="

echo "📦 1. Installation backend"
cd backend
npm install
npm run build
cd ..

echo "🔨 2. Compilation smart contracts"
cd contracts
npx hardhat compile

echo "🚀 3. Déploiement OmniUtil"
npx hardhat run scripts/deploy.ts --network bscTestnet

echo "🧬 4. Extraction ABI"
cd ..
./scripts/extract_abi.sh

echo "✅ OmniUtil est OPÉRATIONNEL"
