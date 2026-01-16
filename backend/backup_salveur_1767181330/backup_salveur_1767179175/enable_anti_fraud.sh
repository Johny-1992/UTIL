#!/bin/bash
set -e

echo "🛡️ Activation ANTI-FRAUDE OmniUtil..."

mkdir -p src/utils

# 1️⃣ Création du guard anti-fraude
cat << 'EOF' > src/utils/antiFraudGuard.ts
import { audit } from "./auditLogger";

const MAX_REWARD_PER_TX = 1000;
const MAX_DAILY_REWARD = 5000;
const MIN_TX_INTERVAL_MS = 30_000;

const userLastTx: Record<string, number> = {};
const userDailyTotal: Record<string, number> = {};

export const antiFraudCheck = (
  userId: string,
  amount: number
) => {
  const now = Date.now();

  if (amount > MAX_REWARD_PER_TX) {
    audit("FRAUD_BLOCK", { userId, reason: "AMOUNT_TOO_HIGH", amount });
    throw new Error("Amount exceeds per-transaction limit");
  }

  if (userLastTx[userId] && now - userLastTx[userId] < MIN_TX_INTERVAL_MS) {
    audit("FRAUD_BLOCK", { userId, reason: "TOO_FREQUENT" });
    throw new Error("Too many transactions");
  }

  userDailyTotal[userId] = (userDailyTotal[userId] || 0) + amount;

  if (userDailyTotal[userId] > MAX_DAILY_REWARD) {
    audit("FRAUD_BLOCK", { userId, reason: "DAILY_LIMIT" });
    throw new Error("Daily reward limit reached");
  }

  userLastTx[userId] = now;
};
EOF

# 2️⃣ Injection dans rewardsService
sed -i '1i import { antiFraudCheck } from "../utils/antiFraudGuard";' src/services/rewardsService.ts

sed -i '/calculateRewards/ a\  antiFraudCheck(userId, amount);' src/services/rewardsService.ts
sed -i '/transferUtil/ a\  antiFraudCheck(userId, amount);' src/services/rewardsService.ts
sed -i '/convertToUSDT/ a\  antiFraudCheck(userId, amount);' src/services/rewardsService.ts

# 3️⃣ Vérification TypeScript
echo "🧪 Vérification TypeScript..."
rm -rf dist
npx tsc --noEmit

echo "✅ POINT 4 TERMINÉ — ANTI-FRAUDE ACTIF & SÉCURISÉ"
