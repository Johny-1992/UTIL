#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL SALVATEUR ULTIMATE NETWORK FIXER"
echo "================================================="

# 1️⃣ Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
for file in "/root/omniutil/backend/src/api/ai.ts" "/root/omniutil/backend/src/api/partner_validation.ts" "/root/omniutil/backend/src/index.ts"; do
    if [ -f "$file" ]; then
        echo "✅ $file trouvé."
    else
        echo "❌ $file manquant !"
        exit 1
    fi
done

# 2️⃣ Correction index.ts pour PORT et imports
echo "✏️ Correction index.ts pour écoute réseau et imports..."
INDEX_FILE="/root/omniutil/backend/src/index.ts"

# Remplace PORT pour être number
sed -i "s|const PORT = process.env.PORT || 3000;|const PORT = Number(process.env.PORT) || 3000;|" $INDEX_FILE

# Corrige partnerValidationRouter si nécessaire
sed -i "s|partnerValidationRouter|partnerValidation|g" $INDEX_FILE

# 3️⃣ Suppression dist
echo "📦 Suppression /root/omniutil/backend/dist..."
rm -rf /root/omniutil/backend/dist

# 4️⃣ Installation dépendances et compilation
echo "📦 Installation dépendances et compilation TypeScript..."
cd /root/omniutil/backend
npm install
npx tsc
if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la compilation TypeScript."
    exit 1
fi
echo "✅ Compilation terminée."

# 5️⃣ Redémarrage PM2
echo "🔄 Redémarrage PM2..."
pm2 delete omniutil-api 2>/dev/null
pm2 start dist/index.js --name omniutil-api
pm2 save

# 6️⃣ Vérification endpoints
echo "🌐 Vérification endpoints..."
for endpoint in "http://127.0.0.1:3000/health" \
                "http://127.0.0.1:3000/api/partner/onboard" \
                "http://127.0.0.1:3000/api/ai/status"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" $endpoint)
    if [ "$STATUS" == "200" ]; then
        echo "$endpoint → ✅ OK"
    else
        echo "$endpoint → ⚠️ HTTP $STATUS"
    fi
done

echo "🎉 STEP 3 FINAL SALVATEUR ULTIMATE NETWORK FIXER TERMINÉ !"
