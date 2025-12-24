#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 ULTIMATE FIXER 2.0"
echo "================================================="

BASE_DIR="/root/omniutil/backend"
SRC_DIR="$BASE_DIR/src"
DIST_DIR="$BASE_DIR/dist"
PM2_APP="omniutil-api"

# 1️⃣ Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
FILES=("api/ai.ts" "api/partner_validation.ts" "index.ts")
ALL_FOUND=true
for f in "${FILES[@]}"; do
    if [ ! -f "$SRC_DIR/$f" ]; then
        echo "❌ $f introuvable !"
        ALL_FOUND=false
    else
        echo "✅ $f trouvé."
    fi
done
$ALL_FOUND || { echo "❌ Fichiers essentiels manquants, arrêt."; exit 1; }

# 2️⃣ Correction des imports/exports
echo "✏️ Correction imports/exports..."
INDEX_FILE="$SRC_DIR/index.ts"
if grep -q "partnerValidationRouter" "$INDEX_FILE"; then
    sed -i 's/partnerValidationRouter/partnerValidation/g' "$INDEX_FILE"
    echo "✅ partnerValidationRouter → partnerValidation"
fi

# 3️⃣ Suppression dist
echo "📦 Suppression $DIST_DIR..."
rm -rf "$DIST_DIR"

# 4️⃣ Installation dépendances et compilation
echo "📦 Installation dépendances..."
npm install --prefix "$BASE_DIR"
echo "📦 Compilation TypeScript..."
npx tsc -p "$BASE_DIR/tsconfig.json"
if [ $? -ne 0 ]; then
    echo "❌ Erreur de compilation !"
    exit 1
fi
echo "✅ Compilation terminée."

# 5️⃣ Redémarrage PM2
echo "🔄 Redémarrage PM2..."
pm2 delete "$PM2_APP" >/dev/null 2>&1
pm2 start "$DIST_DIR/index.js" --name "$PM2_APP"
pm2 save

# 6️⃣ Vérification endpoints
echo "🌐 Vérification endpoints..."
URLS=("/health" "/api/partner/onboard" "/api/ai/status")
for url in "${URLS[@]}"; do
    echo -n "$url → "
    for i in {1..5}; do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000$url)
        if [ "$STATUS" == "200" ]; then
            echo "✅ HTTP 200"
            break
        else
            echo -n "HTTP $STATUS, retrying... "
            sleep 2
            pm2 restart "$PM2_APP" >/dev/null
        fi
        if [ "$i" -eq 5 ]; then
            echo "❌ Toujours non disponible"
        fi
    done
done

echo "🎉 STEP 3 ULTIMATE FIXER 2.0 TERMINÉ !"
