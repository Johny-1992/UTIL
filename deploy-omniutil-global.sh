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
# Assurez-vous que le projet Vercel est déjà linked
vercel link --yes
vercel --prod --yes
echo "✅ Frontend déployé sur Vercel"

# === 4️⃣ Backend Deployment sur Render ===
echo "🌐 Déploiement backend sur Render"
# Assurez-vous que vous avez Render CLI installé et configuré
# Remplacez <SERVICE_ID_BACKEND> par l'ID réel de votre service backend Render
# render services redeploy <SERVICE_ID_BACKEND>
echo "⚠️ Reminder: Vérifiez le SERVICE_ID_BACKEND dans le script avant le déploiement"
echo "✅ Backend prêt sur Render"

# === 5️⃣ Fin ===
echo "🎯 Déploiement global terminé !"
echo "Frontend URL : https://frontend-<ton-projet>.vercel.app"
echo "Backend URL  : <ton-backend-render-url>"
