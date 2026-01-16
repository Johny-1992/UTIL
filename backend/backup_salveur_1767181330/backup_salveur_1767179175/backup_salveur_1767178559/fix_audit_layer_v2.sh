#!/bin/bash
set -e

echo "🧯 Correction AUDIT OmniUtil – version STABLE (v2)..."

FILE="src/services/rewardsService.ts"

cat << 'EOF' > $FILE
import { audit } from "../utils/auditLogger";
import { users } from "../models/userModel";
import { partners } from "../models/partnerModel";

/**
 * Calcul des rewards
 */
export const calculateRewards = (
  partnerId: string,
  userId: string,
  amountSpent: number
) => {
  const partner = partners[partnerId];
  if (!partner) throw new Error("Partner inconnu");

  const utilEarned = amountSpent * partner.rewardRate;
  const fees = utilEarned * 0.1;
  const netUtil = utilEarned - fees;

  users[userId].balance += netUtil;

  audit("CALCULATE_REWARDS", {
    partnerId,
    userId,
    amountSpent,
    utilEarned,
    netUtil
  });

  return {
    utilEarned,
    fees,
    netUtil,
    newBalance: users[userId].balance
  };
};

/**
 * Transfert interne UTIL
 */
export const transferUtil = (
  fromUserId: string,
  toUserId: string,
  amount: number
) => {
  if (users[fromUserId].balance < amount) {
    throw new Error("Solde insuffisant");
  }

  users[fromUserId].balance -= amount;
  users[toUserId].balance += amount;

  audit("TRANSFER_UTIL", {
    fromUserId,
    toUserId,
    amount
  });

  return {
    success: true,
    newBalanceFrom: users[fromUserId].balance,
    newBalanceTo: users[toUserId].balance
  };
};

/**
 * Conversion UTIL → USDT
 */
export const convertToUSDT = (userId: string, amount: number) => {
  if (users[userId].balance < amount) {
    throw new Error("Solde insuffisant");
  }

  users[userId].balance -= amount;

  audit("CONVERT_TO_USDT", {
    userId,
    amount
  });

  return {
    success: true,
    remainingBalance: users[userId].balance
  };
};
EOF

echo "🧪 Vérification TypeScript..."
npx tsc --noEmit

echo "✅ POINT 3 TERMINÉ — AUDIT SOLIDE & ARCHITECTURE SAINE"
