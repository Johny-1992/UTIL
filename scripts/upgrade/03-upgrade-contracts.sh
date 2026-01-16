#!/bin/bash
echo "🚀 Upgrade Contracts"
cd /root/omniutil || exit

# Installer Hardhat si nécessaire
npm install --save-dev hardhat

# Compilation des contrats
npx hardhat compile

echo "✅ Contracts compilés"
