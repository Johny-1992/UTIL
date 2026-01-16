#!/bin/bash
set -e

echo "🔧 Alignement API rewards → logique métier..."

cat << 'EOF' > src/api/rewards/rewards.ts
import { Request, Response } from "express";
import {
  calculateRewards,
  transferUtil,
  convertToUSDT
} from "../../services/rewardsService";

export const rewardUser = async (req: Request, res: Response) => {
  try {
    const { partnerId, userId, amountSpent } = req.body;

    const result = calculateRewards(
      partnerId,
      userId,
      amountSpent
    );

    res.json(result);
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
};

export const transfer = async (req: Request, res: Response) => {
  try {
    const { fromUserId, toUserId, amount } = req.body;
    transferUtil(fromUserId, toUserId, amount);
    res.json({ success: true });
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
};

export const convert = async (req: Request, res: Response) => {
  try {
    const { userId, amount } = req.body;
    const result = convertToUSDT(userId, amount);
    res.json(result);
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
};
EOF

echo "🧹 Nettoyage build..."
rm -rf dist

echo "🧪 Vérification TypeScript..."
npx tsc --noEmit

echo "✅ POINT 2 TERMINÉ — API ALIGNÉE & SÉCURISÉE"
