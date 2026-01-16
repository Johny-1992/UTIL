#!/bin/bash
# deploy-omniutil-final.sh
# Déploiement complet OmniUtil : Frontend Vercel + Backend Render intégré

set -e

# -------------------------------
# Variables Backend Render
# -------------------------------
RENDER_SERVICE_ID="srv-d55nchp5pdvs73c8fr60"
RENDER_BACKEND_URL="https://omniutil.onrender.com"

# -------------------------------
# Frontend : nettoyage, install, build
# -------------------------------
echo "🚀 Déploiement Frontend..."
cd ~/omniutil/frontend

rm -rf .vercel build node_modules

npm install
echo "📦 Dépendances installées"

npm run build
echo "✅ Frontend build terminé"

# -------------------------------
# Vercel : Link et déploiement
# -------------------------------
vercel link --yes
vercel env pull .env.local development --yes

# Injecter directement l'URL backend et le Service ID dans .env.local
sed -i "s|<SERVICE_ID_BACKEND>|$RENDER_SERVICE_ID|g" .env.local
sed -i "s|<ton-backend-render-url>|$RENDER_BACKEND_URL|g" .env.local
echo "🔧 Variables backend injectées dans le frontend"

# Déploiement production sur Vercel
vercel --prod --yes
echo "🌐 Frontend déployé sur Vercel"

# Récupération de l'URL finale du site
FRONTEND_URL=$(vercel --prod inspect | grep 'Production URL' | awk '{print $3}')
echo "🌟 Site opérationnel : $FRONTEND_URL"

# -------------------------------
# Message final
# -------------------------------
echo "🎉 Déploiement complet terminé !"
echo "Frontend : $FRONTEND_URL"
echo "Backend : $RENDER_BACKEND_URL"
echo "Le site est maintenant 100% fonctionnel et prêt à être consulté sur navigateur."
echo "🔍 Pour Google : assurez-vous que le fichier robots.txt et sitemap.xml sont présents pour l’indexation."
