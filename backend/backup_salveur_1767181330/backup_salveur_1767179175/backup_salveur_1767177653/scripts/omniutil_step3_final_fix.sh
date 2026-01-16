#!/bin/bash
# ==============================================
# OMNIUTIL — STEP 3 ULTIMATE PORT & NETWORK FIX
# ==============================================

BACKEND_DIR="/root/omniutil/backend"
SRC_FILE="$BACKEND_DIR/src/index.ts"
DIST_FILE="$BACKEND_DIR/dist/index.js"
APP_NAME="omniutil-api"

echo "📦 Vérification fichiers essentiels..."
if [ ! -f "$SRC_FILE" ]; then
    echo "❌ $SRC_FILE introuvable !"
    exit 1
fi
echo "✅ Fichier $SRC_FILE trouvé."

# --- Correction PORT dans index.ts ---
echo "✏️ Correction PORT pour type number..."
# Remplacer toute ligne PORT par une version sûre
sed -i '/const PORT/ c\const PORT: number = Number(process.env.PORT) || 3000;' "$SRC_FILE"

# --- Suppression dist ---
echo "📦 Suppression $BACKEND_DIR/dist..."
rm -rf "$BACKEND_DIR/dist"

# --- Installation dépendances ---
echo "📦 Installation dépendances..."
cd "$BACKEND_DIR"
npm install

# --- Compilation TypeScript ---
echo "📦 Compilation TypeScript..."
tsc
if [ $? -ne 0 ]; then
    echo "❌ Erreur compilation TypeScript."
    exit 1
fi
echo "✅ Compilation terminée."

# --- Redémarrage PM2 ---
echo "🔄 Redémarrage PM2..."
pm2 delete "$APP_NAME" 2>/dev/null
pm2 start "$DIST_FILE" --name "$APP_NAME"
pm2 save

# --- Test endpoint /health ---
echo "🌐 Vérification /health..."
sleep 2
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/health)

if [ "$HTTP_STATUS" = "200" ]; then
    echo "🎉 /health disponible ! Server opérationnel."
else
    echo "⚠️ /health non disponible (HTTP $HTTP_STATUS). Vérifie les logs PM2 avec 'pm2 logs $APP_NAME'."
fi
