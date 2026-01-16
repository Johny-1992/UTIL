#!/bin/bash
# omniutil_step3_final_autofix_full.sh
# Script ultime pour corriger index.ts, imports, type PORT, compiler TS et relancer PM2

BACKEND_DIR="/root/omniutil/backend"
DIST_DIR="$BACKEND_DIR/dist"
SRC_INDEX="$BACKEND_DIR/src/index.ts"
PM2_APP="omniutil-api"

echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL AUTO-FIXER COMPLET"
echo "================================================="

# 1️⃣ Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
for f in "$BACKEND_DIR/src/api/ai.ts" "$BACKEND_DIR/src/api/partner_validation.ts" "$SRC_INDEX"; do
    if [ ! -f "$f" ]; then
        echo "❌ Fichier manquant : $f"
        exit 1
    else
        echo "✅ $f trouvé."
    fi
done

# 2️⃣ Correction index.ts
echo "✏️ Correction index.ts pour imports et PORT..."
# Remplacer require circulaires par import par défaut
sed -i "s|const partnerValidation = require('./api/partner_validation');|import partnerValidation from './api/partner_validation';|g" "$SRC_INDEX" 2>/dev/null
sed -i "s|const aiRouter = require('./api/ai');|import aiRouter from './api/ai';|g" "$SRC_INDEX" 2>/dev/null
# S'assurer que PORT est un number
sed -i "s|const PORT = process.env.PORT \|\| 3000;|const PORT: number = Number(process.env.PORT) || 3000;|g" "$SRC_INDEX" 2>/dev/null

# 3️⃣ Suppression dist
echo "📦 Suppression $DIST_DIR..."
rm -rf "$DIST_DIR"

# 4️⃣ Installation dépendances
echo "📦 Installation dépendances..."
cd "$BACKEND_DIR"
npm install --legacy-peer-deps

# 5️⃣ Compilation TypeScript
echo "📦 Compilation TypeScript..."
npx tsc
if [ $? -ne 0 ]; then
    echo "❌ Erreur TypeScript, vérifie index.ts et imports."
    exit 1
fi
echo "✅ Compilation terminée."

# 6️⃣ Redémarrage PM2
echo "🔄 Redémarrage PM2..."
pm2 delete $PM2_APP 2>/dev/null
pm2 start "$DIST_DIR/index.js" --name $PM2_APP --watch

# 7️⃣ Vérification /health
echo "🌐 Vérification /health..."
for i in {1..10}; do
    HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/health)
    if [ "$HTTP" = "200" ]; then
        echo "🎉 /health OK ! Étape 3 réussie."
        exit 0
    else
        echo "⚠️ Tentative $i: /health → HTTP $HTTP, redémarrage PM2..."
        pm2 restart $PM2_APP
        sleep 2
    fi
done

echo "❌ /health toujours non disponible après 10 tentatives. Vérifie les logs PM2 avec 'pm2 logs $PM2_APP'."
exit 1
