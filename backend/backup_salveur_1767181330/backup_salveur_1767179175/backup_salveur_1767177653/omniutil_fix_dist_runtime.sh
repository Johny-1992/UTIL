#!/bin/bash
set -e

echo "🛡️ OmniUtil — Correctif DIST & Runtime Node"
echo "=========================================="

# 1️⃣ Vérification tsconfig
if [ ! -f tsconfig.json ]; then
  echo "❌ tsconfig.json manquant"
  exit 1
fi

# 2️⃣ Nettoyage
echo "🧹 Nettoyage dist..."
rm -rf dist

# 3️⃣ Compilation AVEC émission
echo "🧪 Compilation TypeScript (emit JS)..."
npx tsc
echo "✅ dist généré"

# 4️⃣ Vérification fichier
FILE="dist/services/UtilTokenService.js"

if [ ! -f "$FILE" ]; then
  echo "❌ Fichier introuvable : $FILE"
  echo "📂 Contenu dist/services :"
  ls -l dist/services || true
  exit 1
fi

echo "✅ Fichier JS trouvé : $FILE"

# 5️⃣ Test runtime réel
echo "🤖 Test runtime Node (connexion contrat existant)..."

node <<'EOF'
require("dotenv").config();
const { UtilTokenService } = require("./dist/services/UtilTokenService");

(async () => {
  const s = new UtilTokenService();
  const result = await s.simulateReward();
  console.log("✅ Simulation OK :", result);
})();
EOF

echo "🎉 BACKEND OMNIUTIL 100% OPÉRATIONNEL"
