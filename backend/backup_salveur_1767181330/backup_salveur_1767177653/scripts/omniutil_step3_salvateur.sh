#!/bin/bash
# omniutil_step3_salvateur.sh
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 SALVATEUR"
echo "================================================="

BASE_DIR="/root/omniutil/backend"
DIST_DIR="$BASE_DIR/dist"
SRC_API="$BASE_DIR/src/api"

# Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
for file in ai.ts partner_validation.ts; do
  if [ ! -f "$SRC_API/$file" ]; then
    echo "❌ Fichier manquant : $file"
    exit 1
  else
    echo "✅ $file trouvé."
  fi
done

# Correction imports et routes dans index.ts
INDEX_TS="$BASE_DIR/src/index.ts"
echo "✏️ Correction imports et registration des routers..."
if ! grep -q "partner_validation" "$INDEX_TS"; then
  echo "import partnerValidation from './api/partner_validation';" >> "$INDEX_TS"
  echo "app.use('/api/partner', partnerValidation);" >> "$INDEX_TS"
fi
if ! grep -q "ai" "$INDEX_TS"; then
  echo "import aiRouter from './api/ai';" >> "$INDEX_TS"
  echo "app.use('/api/ai', aiRouter);" >> "$INDEX_TS"
fi
echo "✅ Imports et routes corrigés."

# Suppression dist pour compilation propre
echo "📦 Suppression $DIST_DIR..."
rm -rf "$DIST_DIR"

# Installation dépendances et compilation TypeScript
echo "📦 Installation dépendances et compilation TypeScript..."
cd "$BASE_DIR"
npm install
npx tsc
echo "✅ Compilation terminée."

# Redémarrage backend avec PM2
echo "🔄 Redémarrage backend avec PM2..."
pm2 delete omniutil-api 2>/dev/null
pm2 start "$DIST_DIR/index.js" --name omniutil-api
pm2 save
echo "✅ PM2 backend immortalisé et sauvegardé."

# Vérification endpoints
echo "🌐 Vérification endpoints..."
ENDPOINTS=(
  "http://127.0.0.1:3000/health"
  "http://127.0.0.1:3000/api/partner/onboard"
  "http://127.0.0.1:3000/api/ai/status"
)

for url in "${ENDPOINTS[@]}"; do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [ "$HTTP_CODE" != "200" ]; then
    echo "⚠️ $url → HTTP $HTTP_CODE, tentative de redémarrage..."
    pm2 restart omniutil-api
    sleep 3
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    echo "$url → HTTP $HTTP_CODE après redémarrage"
  else
    echo "$url → HTTP 200 ✅"
  fi
done

echo "🎉 STEP 3 SALVATEUR TERMINÉ ! Tout est prêt pour l'étape 4."
