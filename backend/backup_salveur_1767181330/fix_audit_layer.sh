#!/bin/bash
set -e

echo "🧯 Correction couche AUDIT OmniUtil (scope-safe)..."

FILE="src/services/rewardsService.ts"

# Sécurité : retirer les injections incorrectes
sed -i '/audit("TRANSFER_UTIL"/d' $FILE
sed -i '/audit("CONVERT_TO_USDT"/d' $FILE

# Réinjection CONTEXTUELLE et sûre

# transferUtil(fromUserId, toUserId, amount)
sed -i '/export const transferUtil/,/return {/ {
  /return {/ i\
  audit("TRANSFER_UTIL", { fromUserId, toUserId, amount });
}' $FILE

# convertToUSDT(userId, amount)
sed -i '/export const convertToUSDT/,/return {/ {
  /return {/ i\
  audit("CONVERT_TO_USDT", { userId, amount });
}' $FILE

echo "🧪 Vérification TypeScript..."
npx tsc --noEmit

echo "✅ POINT 3 TERMINÉ — AUDIT COHÉRENT & STABLE"
