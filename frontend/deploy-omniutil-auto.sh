#!/bin/bash
set -e

# 🚀 Déploiement OmniUtil Auto

echo "🌍 Vérification backend Render..."
BACKEND_URL="https://omniutil.onrender.com" # URL fixe du backend Render
SERVICE_ID="srv-d55nchp5pdvs73c8fr60"

# Vérifie que le backend est accessible
if curl -s --head --request GET $BACKEND_URL | grep "200 OK" > /dev/null; then
  echo "✅ Backend accessible à $BACKEND_URL"
else
  echo "⚠️ Attention : le backend $BACKEND_URL n'est pas accessible. Vérifie Render."
fi

# 📄 Mise à jour .env.local
ENV_FILE="./frontend/.env.local"
echo "VITE_API_URL=$BACKEND_URL" > $ENV_FILE
echo "✅ .env.local mis à jour avec l'URL du backend"

# 🗺️ Génération sitemap.xml
SITEMAP_FILE="./frontend/public/sitemap.xml"
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $SITEMAP_FILE
echo "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">" >> $SITEMAP_FILE

# Ajouter les routes principales de ton projet ici
ROUTES=("/" "/dashboard" "/rewards" "/airdrops" "/nft-collection")
for route in "${ROUTES[@]}"; do
  echo "  <url>" >> $SITEMAP_FILE
  echo "    <loc>$BACKEND_URL$route</loc>" >> $SITEMAP_FILE
  echo "  </url>" >> $SITEMAP_FILE
done

echo "</urlset>" >> $SITEMAP_FILE
echo "✅ sitemap.xml généré"

# 📦 Build frontend
cd ./frontend
echo "🌐 Compilation frontend..."
npm install
npm run build
echo "✅ Build frontend terminé"

# 🌍 Déploiement Vercel
echo "⏳ Déploiement sur Vercel..."
vercel --prod --yes
echo "✅ Frontend déployé sur Vercel"

# 🔗 URL finale
echo "🌐 URL Vercel : https://frontend-two-beryl-74.vercel.app"
