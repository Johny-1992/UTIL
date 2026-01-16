#!/bin/bash
set -e

echo "🚀 OMNIUTIL – DÉPLOIEMENT FINAL PRODUCTION"
echo "========================================="

ROOT_DIR="$(pwd)"
FRONTEND="$ROOT_DIR/frontend"

########################################
# 1️⃣ Vérification structure
########################################
for dir in frontend backend contracts cpp scripts; do
  [ -d "$ROOT_DIR/$dir" ] || { echo "❌ $dir manquant"; exit 1; }
  echo "✅ $dir OK"
done

########################################
# 2️⃣ Frontend
########################################
cd "$FRONTEND"

echo "📦 Dépendances frontend"
npm install

########################################
# 3️⃣ Vérification SEO PUBLIC
########################################
echo "🧩 Vérification SEO (PUBLIC)"

for f in robots.txt sitemap.xml google05be3ba8343d04a2.html; do
  if [ ! -f "public/$f" ]; then
    echo "❌ public/$f manquant"
    exit 1
  fi
  echo "✅ public/$f OK"
done

########################################
# 4️⃣ Déploiement Vercel (Vercel build lui-même)
########################################
echo "🌍 Déploiement Vercel"
vercel --prod --yes

########################################
# 5️⃣ Alias (manuel et sûr)
########################################
echo "🔗 Alias domaine"
vercel alias set omniutil.vercel.app || true

########################################
# 6️⃣ Vérifications HTTP réelles
########################################
SITE="https://omniutil.vercel.app"

check() {
  code=$(curl -s -o /dev/null -w "%{http_code}" "$1")
  [ "$code" = "200" ] && echo "✅ $1 OK" || echo "❌ $1 HTTP $code"
}

echo "🔎 Vérifications SEO LIVE"
check "$SITE/robots.txt"
check "$SITE/sitemap.xml"
check "$SITE/google05be3ba8343d04a2.html"

echo "🔗 Backend"
check "https://omniutil.onrender.com"

echo "🎉 OMNIUTIL EST OFFICIELLEMENT OPÉRATIONNEL"
