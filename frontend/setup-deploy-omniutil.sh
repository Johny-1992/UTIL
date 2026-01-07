#!/bin/bash
# setup-deploy-omniutil.sh
# Script complet de mise en production OmniUtil (Frontend + Backend + SEO + Vercel + Render)

set -e

FRONTEND_DIR=~/omniutil/frontend
BACKEND_DIR=~/omniutil/backend

echo "🚀 Début de la mise en production OmniUtil..."

# -------------------------
# 1️⃣ Frontend : SEO / manifest / favicons
# -------------------------
echo "🖼️ Vérification des assets frontend..."

# Manifest
MANIFEST_FILE="$FRONTEND_DIR/public/manifest.json"
if [ ! -f "$MANIFEST_FILE" ]; then
cat <<EOL > "$MANIFEST_FILE"
{
  "short_name": "OmniUtil",
  "name": "OmniUtil - Récompenses, NFT et Smart Contracts",
  "icons": [
    {
      "src": "/favicon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/favicon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ],
  "start_url": "/",
  "display": "standalone",
  "theme_color": "#4F46E5",
  "background_color": "#FFFFFF"
}
EOL
echo "✅ manifest.json créé"
else
echo "✅ manifest.json existant, rien à créer"
fi

# robots.txt
ROBOTS_FILE="$FRONTEND_DIR/public/robots.txt"
if [ ! -f "$ROBOTS_FILE" ]; then
cat <<EOL > "$ROBOTS_FILE"
User-agent: *
Allow: /
Sitemap: https://omniutil.vercel.app/sitemap.xml
EOL
echo "✅ robots.txt créé"
else
echo "✅ robots.txt existant, rien à créer"
fi

# SEO tags dans index.html
INDEX_HTML="$FRONTEND_DIR/public/index.html"
if ! grep -q "OmniUtil - Récompenses" "$INDEX_HTML"; then
sed -i '/<head>/a\
<meta name="description" content="OmniUtil vous offre une plateforme de récompenses et d’interactions blockchain pour vos NFT et smart contracts.">\
<meta name="keywords" content="OmniUtil, blockchain, NFT, smart contracts, crypto, rewards">\
<title>OmniUtil - Récompenses, NFT et Smart Contracts</title>' "$INDEX_HTML"
echo "✅ SEO tags injectés dans index.html"
else
echo "✅ SEO tags déjà présents"
fi

# -------------------------
# 2️⃣ Frontend : Build
# -------------------------
echo "🏗️ Installation npm et build frontend..."
cd "$FRONTEND_DIR"
npm install
npm run build
echo "✅ Frontend build terminé"

# -------------------------
# 3️⃣ Frontend : Déploiement Vercel
# -------------------------
echo "🌐 Déploiement frontend sur Vercel..."
if ! command -v vercel &> /dev/null; then
  npm install -g vercel
fi

# Vérification .env pour VITE_API_URL
if ! grep -q "VITE_API_URL" ".env"; then
  echo "VITE_API_URL=https://omniutil-1.onrender.com" >> .env
fi

vercel login --local 2>/dev/null || true
vercel link --yes 2>/dev/null || true
vercel --prod --confirm
echo "✅ Frontend déployé sur Vercel"

# -------------------------
# 4️⃣ Backend : Build et PM2
# -------------------------
echo "💻 Vérification backend..."
cd "$BACKEND_DIR"
npm install
npm run build

# PM2 restart ou start
if pm2 list | grep -q "omniutil-api"; then
  pm2 restart omniutil-api
else
  pm2 start dist/index.js --name omniutil-api
fi
pm2 save
echo "✅ Backend lancé sur Render/PM2"

# -------------------------
# 5️⃣ Backend public URL
# -------------------------
BACKEND_URL="https://omniutil-1.onrender.com"
echo "🔗 Backend disponible sur : $BACKEND_URL"

# -------------------------
# 6️⃣ Génération sitemap
# -------------------------
SITEMAP_FILE="$FRONTEND_DIR/public/sitemap.xml"
cat <<EOL > "$SITEMAP_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://omniutil.vercel.app/</loc>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://omniutil.vercel.app/health</loc>
    <priority>0.8</priority>
  </url>
</urlset>
EOL
echo "✅ sitemap.xml créé"

# -------------------------
# 7️⃣ Résumé final
# -------------------------
echo "🎉 OmniUtil est prêt pour production !"
echo "Frontend : https://omniutil.vercel.app"
echo "Backend : $BACKEND_URL"
echo "Vérifiez SEO, sitemap et robots.txt sur votre frontend"
