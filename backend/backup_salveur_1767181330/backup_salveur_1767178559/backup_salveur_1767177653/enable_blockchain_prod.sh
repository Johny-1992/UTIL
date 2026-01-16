#!/bin/bash
set -e

echo "🚀 Activation MODE BLOCKCHAIN PROD OmniUtil..."

# 1️⃣ Config blockchain
mkdir -p src/config
cat << 'EOF' > src/config/blockchain.ts
export const BLOCKCHAIN_CONFIG = {
  rpcUrl: process.env.RPC_URL || "http://127.0.0.1:8545",
  privateKey: process.env.PRIVATE_KEY || "",
  network: process.env.NETWORK || "local",
};
EOF

# 2️⃣ Provider & signer
mkdir -p src/utils
cat << 'EOF' > src/utils/provider.ts
import { JsonRpcProvider, Wallet } from "ethers";
import { BLOCKCHAIN_CONFIG } from "../config/blockchain";

export const getProvider = () => {
  return new JsonRpcProvider(BLOCKCHAIN_CONFIG.rpcUrl);
};

export const getSigner = () => {
  if (!BLOCKCHAIN_CONFIG.privateKey) {
    throw new Error("PRIVATE_KEY manquante en production");
  }
  return new Wallet(BLOCKCHAIN_CONFIG.privateKey, getProvider());
};
EOF

# 3️⃣ OmniUtil Contract PROD/DEV
cat << 'EOF' > src/utils/omniUtilContract.ts
import { Contract } from "ethers";
import abiJson from "./omniutil_abi.json";
import { getProvider, getSigner } from "./provider";
import { OMNIUTIL_CONTRACT_ADDRESS } from "./contracts";

const abi: any = (abiJson as any).abi ?? abiJson;

export const getOmniUtilContract = () => {
  const isProd = process.env.NODE_ENV === "production";
  const signerOrProvider = isProd ? getSigner() : getProvider();

  return new Contract(
    OMNIUTIL_CONTRACT_ADDRESS,
    abi,
    signerOrProvider as any
  ) as any;
};
EOF

# 4️⃣ Nettoyage ancien build
rm -rf dist

echo "🧪 Vérification TypeScript..."
npx tsc --noEmit

echo "🎉 MODE BLOCKCHAIN PROD ACTIVÉ AVEC SUCCÈS"
