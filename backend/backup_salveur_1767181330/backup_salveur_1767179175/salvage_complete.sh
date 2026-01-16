#!/bin/bash
set -e

echo "🚀 Début du sauvetage complet OmniUtil Backend..."

# 1️⃣ Corriger tous les catch (error) pour typer unknown
echo "🔧 Typage des catch (error) en (error as Error)"
find src -type f -name "*.ts" -exec sed -i "s/error\.message/(error as Error).message/g" {} \;

# 2️⃣ Corriger les chemins relatifs pour onchain et services
echo "🔧 Correction des imports onchain et services"
find src/services -type f -name "*.ts" -exec sed -i "s|../src/onchain/ledger|../onchain/ledger|g" {} \;
find src/services -type f -name "*.ts" -exec sed -i "s|../fraud_detection|../fraud_detection|g" {} \;

# 3️⃣ Ajouter index signatures dans userModel et partnerModel
echo "🔧 Ajout des index signatures dans userModel.ts et partnerModel.ts"
cat << 'EOF' > src/models/userModel.ts
export interface User { balance: number; }
export interface Users { [key: string]: User; }
export const users: Users = {
  u1: { balance: 0 },
  u2: { balance: 0 },
};
export const addBalance = (userId: string, amount: number): number => {
  users[userId].balance += amount;
  return users[userId].balance;
};
EOF

cat << 'EOF' > src/models/partnerModel.ts
export interface Partner { rewardRate: number; }
export interface Partners { [key: string]: Partner; }
export const partners: Partners = {
  p1: { rewardRate: 0.1 },
  p2: { rewardRate: 0.2 },
};
EOF

# 4️⃣ Corriger rewardsService.ts pour index signatures
echo "🔧 Correction des index signatures dans rewardsService.ts"
sed -i "1i import { users } from '../models/userModel'; import { partners } from '../models/partnerModel';" src/services/rewardsService.ts

# 5️⃣ Corriger logger, JSON ABI et ethers providers
echo "🔧 Création d'un logger simple et fix ethers"
cat << 'EOF' > src/utils/logger.ts
export default { info: console.log, warn: console.warn, error: console.error };
EOF

cp ../contracts/artifacts/contracts/OmniUtil.sol/OmniUtil.json src/utils/omniutil_abi.json

sed -i "s/ethers\.providers\.Provider/ethers\.Provider/g" src/utils/contracts.ts

# 6️⃣ Ajouter types pour JSON import si nécessaire
echo "🔧 Création d'un module .d.ts pour JSON"
cat << 'EOF' > src/types/json.d.ts
declare module "*.json" {
  const value: any;
  export default value;
}
EOF

# 7️⃣ Recompiler TypeScript
echo "📦 Compilation TypeScript..."
npx tsc

# 8️⃣ Exécuter le test compilé
echo "✅ Exécution du test OmniUtil compilé..."
node dist/tests/testOmniUtilFull.js

echo "🎉 Sauvetage complet réussi ! OmniUtil Backend prêt à l'emploi."
