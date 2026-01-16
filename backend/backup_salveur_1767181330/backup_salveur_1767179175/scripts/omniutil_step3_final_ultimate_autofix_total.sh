#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL ULTIMATE AUTO-FIX TOTAL"
echo "================================================="

SRC_DIR="/root/omniutil/backend/src"
DIST_DIR="/root/omniutil/backend/dist"
PM2_APP="omniutil-api"

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

# Correction index.ts
echo "✏️ Correction index.ts pour PORT et imports..."
sed -i 's/const PORT = process.env.PORT || 3000;/const PORT = Number(process.env.PORT) || 3000;/' $SRC_DIR/index.ts
sed -i 's/partnerValidationRouter/partnerValidation/' $SRC_DIR/index.ts
sed -i 's/app\.get("\/health", .*);/if (!app._router.stack.some(r => r.route && r.route.path===\"\/health\")) app.get(\"\/health\", (req,res)=>res.status(200).json({status:\"ok\"}));/' $SRC_DIR/index.ts

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
    echo "❌ Erreur lors de la compilation TypeScript. Tentative de correction automatique..."
    # Retry fix
    sed -i 's/const PORT: any/const PORT: number/' $SRC_DIR/index.ts
    npx tsc || { echo "❌ Impossible de compiler après tentative auto-fix"; exit 1; }
fi
echo "✅ Compilation terminée."

# Fonction pour vérifier et fixer endpoints
check_endpoints() {
    URLS=("http://127.0.0.1:3000/health" "http://127.0.0.1:3000/api/partner/onboard" "http://127.0.0.1:3000/api/ai/status")
    for URL in "${URLS[@]}"; do
        RETRIES=10
        COUNT=0
        while [ $COUNT -lt $RETRIES ]; do
            STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)
            if [ "$STATUS" == "200" ]; then
                echo "$URL → HTTP 200 ✅"
                break
            else
                echo "$URL → HTTP $STATUS, tentative de correction ($((COUNT+1))/$RETRIES)"
                pm2 restart $PM2_APP
                sleep 2
                COUNT=$((COUNT+1))
            fi
        done
        if [ $COUNT -eq $RETRIES ]; then
            echo "❌ $URL toujours non disponible après $RETRIES tentatives."
        fi
    done
}

# Redémarrage PM2 initial
echo "🔄 Redémarrage PM2..."
pm2 delete $PM2_APP 2>/dev/null
pm2 start $DIST_DIR/index.js --name $PM2_APP
pm2 save

# Vérification et auto-fix endpoints
echo "🌐 Vérification et auto-fix endpoints..."
check_endpoints

echo "🎉 STEP 3 FINAL ULTIMATE AUTO-FIX TOTAL TERMINÉ !"
