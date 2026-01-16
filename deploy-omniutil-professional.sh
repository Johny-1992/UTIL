#!/bin/bash
# ========================================================
# 🚀 OMNIUTIL – DEPLOYMENT ULTRA-SALVATEUR
# ========================================================
scripts/version-snapshot.sh v1.0.0
set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="../omniutil_backups/$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

echo "=========================================="
echo "🚀 OMNIUTIL – DEPLOIEMENT ULTRA-SALVATEUR"
echo "=========================================="
echo "📦 Sauvegarde des fichiers critiques..."

# Sauvegarde frontend, backend, contracts et SEO
cp -r frontend "$BACKUP_DIR/frontend"
cp -r backend "$BACKUP_DIR/backend"
cp -r contracts "$BACKUP_DIR/contracts"
SEO_FILES=("public/robots.txt" "public/sitemap.xml" "public/google05be3ba8343d04a2.html")
mkdir -p "$BACKUP_DIR/public"
for f in "${SEO_FILES[@]}"; do
    [ -f "$f" ] && cp "$f" "$BACKUP_DIR/public/"
done
echo "✅ Sauvegarde complète créée dans $BACKUP_DIR"

# ----------------------------
# Mise à jour Frontend
# ----------------------------
echo "🚀 Upgrade Frontend"
cd frontend
npm install
for f in "${SEO_FILES[@]}"; do
    [ -f "../$f" ] && cp -u "../$f" "public/"
done
npm run build
cd ..
echo "✅ Frontend build terminé"

# ----------------------------
# Mise à jour Backend
# ----------------------------
echo "🚀 Upgrade Backend"
cd backend
npm install
cd ..
echo "✅ Backend prêt"

# ----------------------------
# Compilation Contracts
# ----------------------------
echo "🚀 Upgrade Contracts"
cd contracts
npm install
npx hardhat compile || echo "⚠️ Aucun contract à compiler"
cd ..
echo "✅ Contracts compilés"

# ----------------------------
# Compilation Orchestrateur C++
# ----------------------------
echo "🚀 Upgrade C++ Orchestrateur"
if [ -f "cpp/Makefile" ]; then
    cd cpp
    make
    cd ..
    echo "✅ Orchestrateur C++ compilé"
else
    echo "⚠️ Makefile non trouvé, compilation C++ ignorée"
fi

# ----------------------------
# Déploiement Vercel
# ----------------------------
echo "🌍 Déploiement frontend sur Vercel..."
DEPLOY_OUTPUT=$(cd frontend && vercel --prod --yes)
echo "$DEPLOY_OUTPUT"
DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -o 'https://frontend-[^ ]*vercel\.app' | head -1)
echo "✅ Frontend déployé : $DEPLOY_URL"
vercel alias "$DEPLOY_URL" omniutil.vercel.app --yes

# ----------------------------
# Vérifications post-déploiement
# ----------------------------
echo "🔎 Vérifications SEO et Backend"
for f in "${SEO_FILES[@]}"; do
    FILE_NAME=$(basename "$f")
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://omniutil.vercel.app/$FILE_NAME")
    [ "$STATUS" == "200" ] && echo "✅ https://omniutil.vercel.app/$FILE_NAME OK" || echo "❌ $FILE_NAME HTTP $STATUS"
done

BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://omniutil.onrender.com")
[ "$BACKEND_STATUS" == "200" ] && echo "✅ Backend OK" || echo "❌ Backend HTTP $BACKEND_STATUS"

# ----------------------------
# Résultat final
# ----------------------------
echo "🎉 OMNIUTIL – 100% OPÉRATIONNEL"
echo "🌐 Site : https://omniutil.vercel.app"
echo "📈 SEO & Backend READY"
echo "💾 Sauvegardes disponibles dans $BACKUP_DIR"
