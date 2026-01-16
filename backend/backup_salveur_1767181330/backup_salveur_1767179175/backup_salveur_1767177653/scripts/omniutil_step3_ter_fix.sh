#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 TER SUPERFIX: ROUTES & AI"
echo "================================================="

BACKEND_DIR="/root/omniutil/backend"
INDEX_FILE="$BACKEND_DIR/src/index.ts"

cd $BACKEND_DIR || exit 1

# 1️⃣ Vérification fichiers
echo "📦 Vérification fichiers essentiels..."
for file in "src/api/ai.ts" "src/api/partner_validation.ts"; do
    if [ ! -f "$BACKEND_DIR/$file" ]; then
        echo "❌ Fichier manquant : $file"
        exit 1
    else
        echo "✅ $file trouvé."
    fi
done

# 2️⃣ Correction imports dans index.ts
echo "✏️ Correction imports dans index.ts..."
sed -i "s|import .*ai.*|import aiRouter from './api/ai';|" $INDEX_FILE
sed -i "s|import .*partner.*|import partnerRouter from './api/partner_validation';|" $INDEX_FILE

# Ajout routes si absentes
grep -q "app.use('/api/ai', aiRouter);" $INDEX_FILE || echo "app.use('/api/ai', aiRouter);" >> $INDEX_FILE
grep -q "app.use('/api/partner', partnerRouter);" $INDEX_FILE || echo "app.use('/api/partner', partnerRouter);" >> $INDEX_FILE

echo "✅ Imports et routes corrigés."

# 3️⃣ Supprimer dist/
echo "📦 Suppression dist/ pour compilation propre..."
rm -rf $BACKEND_DIR/dist/*

# 4️⃣ Installer dépendances
echo "📦 Vérification et installation dépendances..."
npm install

# 5️⃣ Compiler TypeScript
echo "📦 Compilation TypeScript..."
npx tsc
if [ $? -ne 0 ]; then
    echo "❌ Erreur compilation TypeScript"
    exit 1
fi

# 6️⃣ Redémarrer PM2
echo "🔄 Redémarrage PM2..."
pm2 delete omniutil-api
pm2 start $BACKEND_DIR/dist/index.js --name omniutil-api
pm2 save

# 7️⃣ Vérification endpoints
echo "🌐 Vérification endpoints..."
sleep 2
for endpoint in "/health" "/api/ai/status" "/api/partner/onboard"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000$endpoint)
    echo "$endpoint → HTTP $STATUS"
done

echo "🎉 STEP 3 TER COMPLET !"
