#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL SALVATEUR ULTIMATE FIXED"
echo "================================================="

SRC_DIR="/root/omniutil/backend/src"
DIST_DIR="/root/omniutil/backend/dist"

# Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
for FILE in "api/ai.ts" "api/partner_validation.ts" "index.ts"; do
    if [ -f "$SRC_DIR/$FILE" ]; then
        echo "✅ $SRC_DIR/$FILE trouvé."
    else
        echo "❌ $SRC_DIR/$FILE manquant."
        exit 1
    fi
done

# Correction index.ts pour PORT et imports
echo "✏️ Correction index.ts pour PORT et imports..."
# Corriger PORT pour TypeScript
sed -i 's/const PORT = process.env.PORT || 3000;/const PORT = Number(process.env.PORT) || 3000;/' $SRC_DIR/index.ts
# Correction automatique partnerValidationRouter si présent
sed -i 's/partnerValidationRouter/partnerValidation/' $SRC_DIR/index.ts

# Suppression dist
echo "📦 Suppression $DIST_DIR..."
rm -rf $DIST_DIR

# Installation dépendances
echo "📦 Installation dépendances..."
cd /root/omniutil/backend
npm install

# Compilation TypeScript
echo "📦 Compilation TypeScript..."
npx tsc
if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la compilation TypeScript."
    exit 1
fi
echo "✅ Compilation terminée."

# Redémarrage PM2
echo "🔄 Redémarrage PM2..."
pm2 delete omniutil-api 2>/dev/null
pm2 start $DIST_DIR/index.js --name omniutil-api
pm2 save

# Vérification endpoints
echo "🌐 Vérification endpoints..."
URLS=("http://127.0.0.1:3000/health" "http://127.0.0.1:3000/api/partner/onboard" "http://127.0.0.1:3000/api/ai/status")
for URL in "${URLS[@]}"; do
    RETRIES=5
    COUNT=0
    while [ $COUNT -lt $RETRIES ]; do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)
        if [ "$STATUS" == "200" ]; then
            echo "$URL → HTTP 200 ✅"
            break
        else
            echo "$URL → HTTP $STATUS, retrying... ($((COUNT+1))/$RETRIES)"
            COUNT=$((COUNT+1))
            pm2 restart omniutil-api
            sleep 2
        fi
    done
    if [ $COUNT -eq $RETRIES ]; then
        echo "❌ $URL toujours non disponible après $RETRIES tentatives."
    fi
done

echo "🎉 STEP 3 FINAL SALVATEUR ULTIMATE FIXED TERMINÉ !"
