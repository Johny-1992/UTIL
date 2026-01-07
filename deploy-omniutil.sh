#!/bin/bash
set -e

echo "🚀 Déploiement global OmniUtil – mode PRO"
echo "========================================"

ROOT_DIR="$HOME/omniutil"
FRONTEND_DIR="$ROOT_DIR/frontend"
BACKEND_DIR="$ROOT_DIR/backend"

### 1️⃣ Vérifications
echo "🔍 Vérifications de base..."

command -v node >/dev/null || { echo "❌ Node.js manquant"; exit 1; }
command -v npm >/dev/null || { echo "❌ npm manquant"; exit 1; }
command -v vercel >/dev/null || { echo "❌ Vercel CLI manquant"; exit 1; }

[ -d "$FRONTEND_DIR" ] || { echo "❌ frontend introuvable"; exit 1; }
[ -d "$BACKEND_DIR" ] || { echo "❌ backend introuvable"; exit 1; }

echo "✅ Environnement OK"

### 2️⃣ Backend
echo ""
echo "⚙️ Backend – build TypeScript"

cd "$BACKEND_DIR"

npm install
npm run build

echo "✅ Backend build OK"

### 3️⃣ Frontend
echo ""
echo "🎨 Frontend – vérification env & build"

cd "$FRONTEND_DIR"

# Vérification env
if [ ! -f ".env" ] && [ ! -f ".env.local" ]; then
  echo "❌ Aucun fichier .env trouvé"
  exit 1
fi

API_URL=$(grep -h "VITE_API_URL" .env .env.local 2>/dev/null || true)

if [[ -z "$API_URL" ]]; then
  echo "❌ VITE_API_URL manquant"
  exit 1
fi

echo "🌐 API utilisée : $API_URL"

npm install
npm run build

echo "✅ Frontend build OK"

### 4️⃣ Déploiement Vercel
echo ""
echo "🌍 Déploiement frontend sur Vercel (production)"

vercel --prod --yes

### 5️⃣ Résumé
echo ""
echo "🎉 DÉPLOIEMENT TERMINÉ AVEC SUCCÈS"
echo "--------------------------------"
echo "🌐 Frontend : https://omniutil.vercel.app"
echo "🔗 Backend  : https://omniutil-1.onrender.com"
echo ""
echo "🚀 OmniUtil est LIVE et professionnel."
