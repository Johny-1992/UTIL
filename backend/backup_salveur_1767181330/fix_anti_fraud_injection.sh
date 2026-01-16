#!/bin/bash
set -e

echo "🧯 Correction injection ANTI-FRAUDE OmniUtil..."

FILE="src/services/rewardsService.ts"

# 1️⃣ Suppression de toutes les injections cassées
sed -i '/antiFraudCheck(/d' "$FILE"

# 2️⃣ Réinjection SAFE après ouverture de bloc des fonctions
sed -i '/calculateRewards.*=> {/a\  antiFraudCheck(userId, amountSpent);' "$FILE"
sed -i '/transferUtil.*=> {/a\  antiFraudCheck(userId, amount);' "$FILE"
sed -i '/convertToUSDT.*=> {/a\  antiFraudCheck(userId, amount);' "$FILE"

# 3️⃣ Vérification TypeScript
echo "🧪 Vérification TypeScript..."
rm -rf dist
npx tsc --noEmit

echo "✅ ANTI-FRAUDE — INJECTION CORRIGÉE & STABLE"
