#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL ULTIMATE AUTO-FIXER"
echo "================================================="

BASE_DIR="/root/omniutil/backend"
SRC_DIR="$BASE_DIR/src"
DIST_DIR="$BASE_DIR/dist"

# 1️⃣ Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
[[ -f "$SRC_DIR/api/ai.ts" ]] && echo "✅ ai.ts trouvé." || { echo "❌ ai.ts manquant!"; exit 1; }
[[ -f "$SRC_DIR/api/partner_validation.ts" ]] && echo "✅ partner_validation.ts trouvé." || { echo "❌ partner_validation.ts manquant!"; exit 1; }
[[ -f "$SRC_DIR/index.ts" ]] && echo "✅ index.ts trouvé." || { echo "❌ index.ts manquant!"; exit 1; }

# 2️⃣ Correction index.ts
echo "✏️ Correction index.ts..."
INDEX_FILE="$SRC_DIR/index.ts"

# Remplacement partnerValidationRouter → partnerValidation et ajout /health si absent
sed -i "s/partnerValidationRouter/partnerValidation/g" $INDEX_FILE
grep -q "app.get('/health'" $INDEX_FILE || echo "app.get('/health', (req,res)=>res.json({status:'ok'}));" >> $INDEX_FILE

# 3️⃣ Suppression dist
echo "📦 Suppression $DIST_DIR..."
rm -rf "$DIST_DIR"

# 4️⃣ Installation dépendances et compilation TS
echo "📦 Installation dépendances..."
cd $BASE_DIR
npm install
echo "📦 Compilation TypeScript..."
npx tsc

# 5️⃣ Redémarrage PM2
echo "🔄 Redémarrage PM2..."
pm2 delete omniutil-api 2>/dev/null
pm2 start $DIST_DIR/index.js --name omniutil-api
pm2 save
pm2 restart omniutil-api --update-env

# 6️⃣ Vérification endpoints
ENDPOINTS=("/health" "/api/partner/onboard" "/api/ai/status")
for endpoint in "${ENDPOINTS[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000$endpoint)
    if [[ "$STATUS" != "200" ]]; then
        echo "⚠️ $endpoint → HTTP $STATUS, tentative de redémarrage..."
        pm2 restart omniutil-api --update-env
    else
        echo "✅ $endpoint → OK"
    fi
done

echo "🎉 STEP 3 FINAL ULTIMATE AUTO-FIXER TERMINÉ !"
