#!/bin/bash
set -e

echo "🚀 Déploiement global OmniUtil – mode PRO"
echo "========================================"

# === 1️⃣ Backend Build ===
echo "⚙️  Backend – build TypeScript"
cd ~/omniutil/backend
npm install
npm run build
echo "✅ Backend build OK"

# === 2️⃣ Frontend Build ===
echo "🎨 Frontend – build React"
cd ~/omniutil/frontend
rm -rf node_modules build .vercel
npm install
npm run build
echo "✅ Frontend build OK"

# === 3️⃣ Frontend Deployment sur Vercel ===
echo "🌍 Déploiement frontend sur Vercel (production)"
vercel link --yes
vercel --prod --yes
echo "✅ Frontend déployé sur Vercel"

# === 4️⃣ Backend Deployment ===
echo "🌐 Déploiement backend"
# Exemple pour Render : remplacer par votre commande réelle de déploiement
# render deploy service --service-id <ID_DU_BACKEND>
echo "⚠️ Reminder: Déploiement backend manuel ou via Render CLI à compléter"

# === 5️⃣ Fin ===
echo "🎯 Déploiement global terminé !"
