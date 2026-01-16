#!/bin/bash
set -e

echo "🔐 Sécurisation logique métier OmniUtil..."

# 1️⃣ Guards centraux
mkdir -p src/security
cat << 'EOF' > src/security/guards.ts
export const assertPositiveAmount = (amount: number) => {
  if (amount <= 0 || Number.isNaN(amount)) {
    throw new Error("Montant invalide");
  }
};

export const assertSufficientBalance = (balance: number, amount: number) => {
  if (balance < amount) {
    throw new Error("Solde insuffisant");
  }
};

export const assertRewardRate = (rate: number) => {
  if (rate <= 0 || rate > 1) {
    throw new Error("Reward rate invalide");
  }
};
EOF

# 2️⃣ Patch rewardsService
cat << 'EOF' > src/services/rewardsService.ts
import { users } from "../models/userModel";
import { partners } from "../models/partnerModel";
import {
  assertPositiveAmount,
  assertSufficientBalance,
  assertRewardRate
} from "../security/guards";

export const calculateRewards = (
  partnerId: string,
  userId: string,
  amountSpent: number
) => {
  assertPositiveAmount(amountSpent);

  const partner = partners[partnerId];
  if (!partner) throw new Error("Partner inconnu");

  assertRewardRate(partner.rewardRate);

  const utilEarned = amountSpent * partner.rewardRate;
  const fees = utilEarned * 0.05;
  const netUtil = utilEarned - fees;

  users[userId].balance += netUtil;

  return { utilEarned, fees, netUtil };
};

export const transferUtil = (
  fromUserId: string,
  toUserId: string,
  amount: number
) => {
  assertPositiveAmount(amount);
  assertSufficientBalance(users[fromUserId].balance, amount);

  users[fromUserId].balance -= amount;
  users[toUserId].balance += amount;

  return true;
};

export const convertToUSDT = (userId: string, amount: number) => {
  assertPositiveAmount(amount);
  assertSufficientBalance(users[userId].balance, amount);

  users[userId].balance -= amount;
  return { success: true };
};
EOF

# 3️⃣ Clean build
rm -rf dist

echo "🧪 Vérification TypeScript..."
npx tsc --noEmit

echo "✅ LOGIQUE MÉTIER SÉCURISÉE"
