#!/bin/bash
# omniutil_phase3_fix.sh
# Fix PM2 + TypeScript + Bun/Node pour OMNIUTIL PHASE 3 IMMORTAL

set -e

echo "🔧 Fixing OMNIUTIL Phase 3 environment..."

# 1️⃣ Installer ts-node et typescript si manquant
echo "📦 Installing ts-node and typescript..."
npm install --save-dev ts-node typescript

# 2️⃣ Vérifier que ts-node est dispo
if ! [ -x "./node_modules/.bin/ts-node" ]; then
    echo "❌ ts-node is still not available. Exiting."
    exit 1
fi
echo "✅ ts-node installed successfully."

# 3️⃣ Ajouter export default dans index.ts si absent
INDEX_FILE="./backend/src/api/index.ts"
if ! grep -q "export default" "$INDEX_FILE"; then
    echo "📝 Adding 'export default app' to index.ts..."
    echo -e "\nexport default app;" >> "$INDEX_FILE"
fi

# 4️⃣ Supprimer ancien PM2
echo "🗑️  Deleting old PM2 process..."
pm2 delete omniutil-api || true

# 5️⃣ Démarrer avec ts-node
echo "🚀 Starting PM2 with ts-node..."
pm2 start "$INDEX_FILE" --name omniutil-api --interpreter ./node_modules/.bin/ts-node

# 6️⃣ Sauvegarder PM2 pour immortal mode
pm2 save

echo "🎉 OMNIUTIL PHASE 3 — IMMORTAL MODE FIXED ✅"
echo "🌍 Check backend: http://localhost:3000/health"
