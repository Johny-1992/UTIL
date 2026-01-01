#!/usr/bin/env bash
set -e

cd backend

echo "🔐 OmniUtil — Audit Blockchain BSC Testnet"

node <<'EOF'
require("dotenv").config()
const { ethers } = require("ethers")

const provider = new ethers.JsonRpcProvider(process.env.BSC_RPC_URL)
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider)

console.log("Wallet:", wallet.address)

provider.getBlockNumber().then(bn => {
  console.log("Block actuel:", bn)
  console.log("✅ RPC OK")
}).catch(err => {
  console.error("❌ RPC FAIL", err)
  process.exit(1)
})
EOF

echo "🎉 Audit Blockchain TERMINÉ"
