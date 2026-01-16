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

# On déploie et on capture l'URL finale automatiquement
FRONTEND_URL=$(vercel --prod --yes | grep -oP 'https://[^\s]+\.vercel\.app')
echo "✅ Frontend déployé sur Vercel"
echo "🌐 Frontend URL : $FRONTEND_URL"

# === 4️⃣ Backend Deployment sur Render ===
echo "🌐 Déploiement backend sur Render"

# On détecte automatiquement le SERVICE_ID depuis Render (si CLI Render installé et connecté)
SERVICE_ID_BACKEND=$(render services list --json | jq -r '.[] | select(.name=="omniutil-backend") | .id')
BACKEND_URL=$(render services list --json | jq -r '.[] | select(.name=="omniutil-backend") | .serviceDetail.url')

if [ -z "$SERVICE_ID_BACKEND" ] || [ -z "$BACKEND_URL" ]; then
    echo "⚠️ Impossible de récupérer automatiquement le Service ID ou l'URL du backend Render."
    echo "Veuillez vérifier que la CLI Render est installée et que vous êtes connecté."
    exit 1
fi

render services redeploy $SERVICE_ID_BACKEND
echo "✅ Backend redeployé"
echo "🌐 Backend URL  : $BACKEND_URL"

# === 5️⃣ Fin ===
echo "🎯 Déploiement global terminé !"
echo "🔗 Frontend : $FRONTEND_URL"
echo "🔗 Backend  : $BACKEND_URL"
