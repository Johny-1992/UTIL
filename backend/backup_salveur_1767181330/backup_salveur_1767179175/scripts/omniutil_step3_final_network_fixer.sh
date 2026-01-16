#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL ULTIMATE NETWORK FIXER"
echo "================================================="

# Chemins essentiels
SRC_DIR="/root/omniutil/backend/src"
DIST_DIR="/root/omniutil/backend/dist"
PM2_APP="omniutil-api"

# Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
for FILE in "$SRC_DIR/api/ai.ts" "$SRC_DIR/api/partner_validation.ts" "$SRC_DIR/index.ts"; do
    if [ -f "$FILE" ]; then
        echo "✅ $FILE trouvé."
    else
        echo "❌ $FILE manquant !"
        exit 1
    fi
done

# Correction index.ts : écoute sur 0.0.0.0 et vérification imports
echo "✏️ Correction index.ts pour écoute réseau et imports..."
sed -i "s/app.listen(\(.*\), .*);/app.listen(\1, '0.0.0.0', () => { console.log('Server running on port', \1); });/" "$SRC_DIR/index.ts"

# Suppression dist
echo "📦 Suppression $DIST_DIR..."
rm -rf "$DIST_DIR"

# Installation dépendances et compilation
echo "📦 Installation dépendances et compilation TypeScript..."
cd /root/omniutil/backend || exit
npm install
npx tsc
if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la compilation TypeScript."
    exit 1
fi
echo "✅ Compilation terminée."

# Redémarrage PM2
echo "🔄 Redémarrage PM2..."
pm2 delete $PM2_APP 2>/dev/null
pm2 start "$DIST_DIR/index.js" --name $PM2_APP
pm2 save

# Vérification endpoints
echo "🌐 Vérification endpoints..."
ENDPOINTS=("http://127.0.0.1:3000/health" "http://127.0.0.1:3000/api/partner/onboard" "http://127.0.0.1:3000/api/ai/status")
for URL in "${ENDPOINTS[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)
    if [ "$STATUS" == "200" ]; then
        echo "✅ $URL → HTTP 200 OK"
    else
        echo "⚠️ $URL → HTTP $STATUS"
    fi
done

echo "🎉 STEP 3 FINAL ULTIMATE NETWORK FIXER TERMINÉ !"
