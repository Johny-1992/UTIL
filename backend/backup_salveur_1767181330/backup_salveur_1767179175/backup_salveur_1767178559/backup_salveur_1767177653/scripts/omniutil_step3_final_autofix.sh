#!/bin/bash
# 🚀 OMNIUTIL — STEP 3 FINAL AUTO-FIX: AI & IMMORTALIZATION

echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL AUTO-FIX: AI & IMMORTALIZATION"
echo "================================================="

BACKEND_DIR="/root/omniutil/backend"
INDEX_FILE="$BACKEND_DIR/src/index.ts"
PARTNER_FILE="$BACKEND_DIR/src/api/partner_validation.ts"

# 1️⃣ Vérification des fichiers
echo "📦 Vérification des fichiers..."
if [[ ! -f "$PARTNER_FILE" ]]; then
  echo "❌ partner_validation.ts manquant !"
  exit 1
fi
echo "✅ partner_validation.ts trouvé."

# 2️⃣ Vérification et correction de l'import dans index.ts
echo "📌 Vérification import dans index.ts..."
if ! grep -q "./api/partner_validation" "$INDEX_FILE"; then
  echo "✏️ Correction import dans index.ts..."
  sed -i "s|import partnerValidation.*|import partnerValidation from './api/partner_validation';|" "$INDEX_FILE"
  echo "✅ Import corrigé."
else
  echo "✅ Import correct."
fi

# 3️⃣ Installation dépendances et compilation
echo "📦 Installation dépendances et compilation TypeScript..."
cd "$BACKEND_DIR" || exit
npm install
npx tsc
echo "✅ Compilation terminée."

# 4️⃣ Redémarrage PM2
echo "🔄 Redémarrage backend avec PM2..."
pm2 restart omniutil-api --update-env
pm2 save
echo "✅ PM2 backend immortalisé et sauvegardé."

# 5️⃣ Vérification du backend
echo "🌐 Vérification backend..."
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/health)
if [[ "$HEALTH" == "200" ]]; then
  echo "✅ Backend opérationnel (HTTP 200)."
else
  echo "⚠️ Backend KO (HTTP $HEALTH). Vérifie les logs : pm2 logs omniutil-api --lines 50"
fi

# 6️⃣ Test endpoint AI Coordinator
echo "🧪 Test AI Coordinator endpoint..."
AI_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/api/ai/status)
if [[ "$AI_TEST" == "200" ]]; then
  echo "✅ AI Coordinator opérationnel (HTTP 200)."
else
  echo "⚠️ AI Coordinator KO (HTTP $AI_TEST). Vérifie les logs : pm2 logs omniutil-api --lines 50"
fi

echo "🎉 STEP 3 FINAL AUTO-FIX TERMINÉ !"
echo "Backend : http://127.0.0.1:3000/health"
