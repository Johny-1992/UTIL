#!/bin/bash
echo "🚀 Upgrade Frontend – Mise à jour et build"
cd /root/omniutil/frontend || exit

# Installer les dépendances
npm install

# Copier fichiers SEO si absents
mkdir -p public
cp -n ../sitemap.xml public/sitemap.xml
cp -n ../google05be3ba8343d04a2.html public/google05be3ba8343d04a2.html
cp -n ../robots.txt public/robots.txt

# Build
npm run build

echo "✅ Frontend build complet"
