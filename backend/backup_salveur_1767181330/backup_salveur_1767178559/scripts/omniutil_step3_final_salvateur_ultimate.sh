#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL SALVATEUR ULTIMATE"
echo "================================================="

# Chemins
SRC_DIR="/root/omniutil/backend/src"
DIST_DIR="/root/omniutil/backend/dist"
PM2_APP="omniutil-api"

# Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
if [[ ! -f "$SRC_DIR/api/ai.ts" || ! -f "$SRC_DIR/api/partner_validation.ts" ]]; then
  echo "❌ Fichiers essentiels manquants !"
  exit 1
fi
echo "✅ Fichiers essentiels trouvés."

# Correction index.ts : utilisation correcte du router
INDEX_FILE="$SRC_DIR/index.ts"
if grep -q "partnerValidationRouter" "$INDEX_FILE"; then
  echo "✏️ Correction de partnerValidationRouter → partnerValidation dans index.ts..."
  sed -i "s/partnerValidationRouter/partnerValidation/g" "$INDEX_FILE"
fi

# Vérifier export du router dans partner_validation.ts
if ! grep -q "export default router" "$SRC_DIR/api/partner_validation.ts"; then
  echo "✏️ Ajout export default router dans partner_validation.ts..."
  sed -i -e "\$a export default router;" "$SRC_DIR/api/partner_validation.ts"
fi

# Supprimer dist pour compilation propre
echo "📦 Suppression $DIST_DIR..."
rm -rf "$DIST_DIR"

# Installer dépendances
echo "📦 Installation dépendances..."
cd /root/omniutil/backend
npm install

# Compilation TypeScript
echo "📦 Compilation TypeScript..."
tsc
if [[ $? -ne 0 ]]; then
  echo "❌ Erreur de compilation TypeScript"
  exit 1
fi
echo "✅ Compilation terminée."

# Redémarrage PM2
echo "🔄 Redémarrage PM2..."
pm2 delete $PM2_APP &> /dev/null
pm2 start "$DIST_DIR/index.js" --name $PM2_APP
pm2 save

# Vérification endpoints
echo "🌐 Vérification endpoints..."
for endpoint in /health /api/partner/onboard /api/ai/status; do
  status=$(curl -o /dev/null -s -w "%{http_code}" http://127.0.0.1:3000$endpoint)
  if [[ "$status" == "200" ]]; then
    echo "$endpoint → HTTP $status ✅"
  else
    echo "$endpoint → HTTP $status ❌"
  fi
done

echo "🎉 STEP 3 FINAL SALVATEUR ULTIMATE TERMINÉ !"
