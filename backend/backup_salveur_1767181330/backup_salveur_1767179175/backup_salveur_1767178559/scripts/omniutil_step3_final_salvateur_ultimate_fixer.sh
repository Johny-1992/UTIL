#!/bin/bash
set -e

echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL SALVATEUR ULTIMATE FIXER"
echo "================================================="

BACKEND_DIR="/root/omniutil/backend"
SRC_DIR="$BACKEND_DIR/src"
DIST_DIR="$BACKEND_DIR/dist"
PM2_APP_NAME="omniutil-api"

# Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
for f in "$SRC_DIR/api/ai.ts" "$SRC_DIR/api/partner_validation.ts"; do
    if [ ! -f "$f" ]; then
        echo "❌ $f introuvable !"
        exit 1
    else
        echo "✅ $f trouvé."
    fi
done

# Correction import router dans index.ts
INDEX_FILE="$SRC_DIR/index.ts"
if grep -q "partnerValidationRouter" "$INDEX_FILE"; then
    echo "✏️ Correction import partnerValidationRouter → partnerValidation..."
    sed -i "s/partnerValidationRouter/partnerValidation/g" "$INDEX_FILE"
fi

# Ajout /health si absent
if ! grep -q "app.get('/health'" "$INDEX_FILE"; then
    echo "✏️ Ajout endpoint /health..."
    echo -e "\napp.get('/health', (_req, res) => res.json({status: 'ok'}));" >> "$INDEX_FILE"
fi

# Supprimer dist pour compilation propre
echo "📦 Suppression $DIST_DIR..."
rm -rf "$DIST_DIR"

# Compilation TypeScript
echo "📦 Compilation TypeScript..."
tsc

# Redémarrage PM2
echo "🔄 Redémarrage backend avec PM2..."
pm2 delete "$PM2_APP_NAME" || true
pm2 start "$DIST_DIR/index.js" --name "$PM2_APP_NAME"
pm2 save

# Boucle vérification endpoints jusqu'à HTTP 200
ENDPOINTS=("/health" "/api/partner/onboard" "/api/ai/status")
for endpoint in "${ENDPOINTS[@]}"; do
    ATTEMPTS=0
    until [ $ATTEMPTS -ge 20 ]; do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:3000$endpoint" || echo "000")
        if [ "$STATUS" == "200" ]; then
            echo "✅ $endpoint → HTTP 200"
            break
        else
            echo "⚠️ $endpoint → HTTP $STATUS, tentative de redémarrage..."
            pm2 restart "$PM2_APP_NAME"
            sleep 3
        fi
        ATTEMPTS=$((ATTEMPTS+1))
    done
    if [ "$STATUS" != "200" ]; then
        echo "❌ $endpoint toujours non disponible après plusieurs tentatives."
    fi
done

echo "🎉 STEP 3 FINAL SALVATEUR ULTIMATE FIX TERMINÉ !"
