#!/bin/bash
# ========================================
# Script de reset / build / run OmniUtil
# ========================================

echo "🌕 RESET COMPLET DU BACKEND OMNIUTIL"

# 1️⃣ Aller dans le dossier backend
cd ~/omniutil/backend || exit 1

# 2️⃣ Supprimer dist existant
echo "🧹 Nettoyage du dossier dist..."
rm -rf dist

# 3️⃣ Installer toutes les dépendances et types TS
echo "📦 Installation des dépendances..."
npm install
npm install --save-dev @types/express @types/node @types/qrcode

# 4️⃣ Compiler TypeScript
echo "⚙️ Compilation TypeScript..."
npx tsc

# 5️⃣ Vérifier si compilation réussie
if [ $? -ne 0 ]; then
    echo "❌ Erreur de compilation TS. Corrige les erreurs et relance."
    exit 1
fi

# 6️⃣ Lancer le serveur backend
echo "🚀 Démarrage du serveur backend sur le port 8080..."
node dist/index.js
