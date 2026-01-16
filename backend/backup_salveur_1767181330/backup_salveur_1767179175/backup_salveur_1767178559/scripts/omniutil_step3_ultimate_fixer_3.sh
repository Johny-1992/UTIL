#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 ULTIMATE FIXER 3.0"
echo "================================================="

# Variables
SRC_DIR="/root/omniutil/backend/src"
DIST_DIR="/root/omniutil/backend/dist"
PM2_APP="omniutil-api"
RETRIES=5

# 1️⃣ Vérification des fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
for file in "$SRC_DIR/api/ai.ts" "$SRC_DIR/api/partner_validation.ts" "$SRC_DIR/index.ts"; do
  if [ -f "$file" ]; then
    echo "✅ $file trouvé."
  else
    echo "❌ $file manquant !"
    exit 1
  fi
done

# 2️⃣ Forcer correction imports/exports et app.listen
echo "✏️ Correction imports/exports et app.listen sur 0.0.0.0:3000..."
INDEX_FILE="$SRC_DIR/index.ts"

# Remplace partnerValidationRouter par partnerValidation si présent
sed -i 's/partnerValidationRouter/partnerValidation/g' "$INDEX_FILE"

# Force app.listen sur 0.0.0.0
sed -i "s/app.listen(\([0-9]*\), .*$/app.listen(\1, '0.0.0.0', () => { console.log('Server running on port \1'); });/" "$INDEX_FILE"

# 3️⃣ Suppression dist
echo "📦 Suppression $DIST_DIR..."
rm -rf "$DIST_DIR"

# 4️⃣ Installation dépendances
echo "📦 Installation dépendances..."
npm install

# 5️⃣ Compilation TypeScript
echo "📦 Compilation TypeScript..."
npx tsc

if [ $? -ne 0 ]; then
  echo "❌ Erreur de compilation TS !"
  exit 1
fi
echo "✅ Compilation terminée."

# 6️⃣ Redémarrage PM2
echo "🔄 Redémarrage PM2..."
pm2 delete "$PM2_APP" 2>/dev/null
pm2 start "$DIST_DIR/index.js" --name "$PM2_APP"
pm2 save

# 7️⃣ Vérification endpoints
echo "🌐 Vérification endpoints..."
ENDPOINTS=( "/health" "/api/partner/onboard" "/api/ai/status" )
for endpoint in "${ENDPOINTS[@]}"; do
  ATTEMPT=1
  while [ $ATTEMPT -le $RETRIES ]; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000$endpoint)
    if [ "$STATUS" == "200" ]; then
      echo "$endpoint → ✅ HTTP 200"
      break
    else
      echo "$endpoint → ⚠️ HTTP $STATUS, retrying... ($ATTEMPT/$RETRIES)"
      pm2 restart "$PM2_APP"
      sleep 3
      ((ATTEMPT++))
    fi
  done
  if [ "$STATUS" != "200" ]; then
    echo "❌ $endpoint toujours non disponible après $RETRIES tentatives."
  fi
done

echo "🎉 STEP 3 ULTIMATE FIXER 3.0 TERMINÉ !"
