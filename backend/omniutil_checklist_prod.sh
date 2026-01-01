#!/usr/bin/env bash
set -euo pipefail

echo "🛡️ OmniUtil — Checklist Production"
echo "================================="

REQUIRED_FILES=(
  "package.json"
  "tsconfig.json"
  "src/index.ts"
  "src/services/PartnerOnboardingService.ts"
  "src/services/UtilTokenService.ts"
  ".env"
)

REQUIRED_ENV=(
  "API_KEY"
  "BSC_RPC_URL"
  "UTIL_TOKEN_ADDRESS"
  "PRIVATE_KEY"
)

echo "📁 Vérification fichiers critiques..."
for f in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "❌ Fichier manquant : $f"
    exit 1
  fi
done
echo "✅ Fichiers OK"

echo
echo "🔐 Vérification variables d'environnement..."
for v in "${REQUIRED_ENV[@]}"; do
  if ! grep -q "^$v=" .env; then
    echo "❌ Variable manquante dans .env : $v"
    exit 1
  fi
done
echo "✅ Variables d'environnement OK"

echo
echo "🧪 Test compilation TypeScript..."
rm -rf dist
npx tsc
echo "✅ Build TypeScript OK"

echo
echo "🎉 Checklist production VALIDÉE"
