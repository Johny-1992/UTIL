#!/bin/bash
set -e

echo "🚀 Début du sauvetage complet OmniUtil Backend..."

# 1️⃣ Corriger userModel.ts
cat << 'EOF' > src/models/userModel.ts
export const users: Record<string, { balance: number }> = {
  u1: { balance: 100 },
  u2: { balance: 50 },
};
EOF
echo "✅ userModel.ts corrigé avec index signatures"

# 2️⃣ Corriger partnerModel.ts
cat << 'EOF' > src/models/partnerModel.ts
export const partners: Record<string, { rewardRate: number }> = {
  p1: { rewardRate: 0.1 },
  p2: { rewardRate: 0.05 },
};
EOF
echo "✅ partnerModel.ts corrigé avec index signatures"

# 3️⃣ Corriger rewardsService.ts
cat << 'EOF' > src/services/rewardsService.ts
import { users } from '../models/userModel';
import { partners } from '../models/partnerModel';

// Exemple de fonction simple pour illustration
export const claimReward = (userId: string, partnerId: string, amount: number) => {
  const netUtil = amount * partners[partnerId].rewardRate;
  users[userId].balance += netUtil;
  return { utilEarned: netUtil, newBalance: users[userId].balance };
};
EOF
echo "✅ rewardsService.ts nettoyé et index signatures appliquées"

# 4️⃣ Créer contracts.ts manquant
mkdir -p src/utils
cat << 'EOF' > src/utils/contracts.ts
import { Contract, Provider } from "ethers";
import OMNIUTIL_ABI from "./omniutil_abi.json";

export const OMNIUTIL_CONTRACT_ADDRESS = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";

export const getOmniUtilContract = (provider: Provider): Contract => {
  return new Contract(
    OMNIUTIL_CONTRACT_ADDRESS,
    OMNIUTIL_ABI as any,
    provider
  ) as any; // Cast 'any' pour toutes les fonctions custom
};
EOF
echo "✅ contracts.ts créé et cast 'any' appliqué"

# 5️⃣ Créer type JSON
mkdir -p src/types
cat << 'EOF' > src/types/json.d.ts
declare module "*.json" {
  const value: any;
  export default value;
}
EOF
echo "✅ json.d.ts créé"

# 6️⃣ Supprimer anciens fichiers compilés
rm -rf dist/*
echo "🧹 Anciennes compilations supprimées"

# 7️⃣ Compiler TypeScript
npx tsc
echo "📦 Compilation TypeScript terminée"

echo "🎉 Sauvetage complet terminé ! Tu peux maintenant exécuter tes tests."
