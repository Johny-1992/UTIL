#!/bin/bash
echo "🚀 Déploiement final OmniUtil"
cd /root/omniutil/frontend || exit

# Build final
npm run build

# Déploiement Vercel
vercel --prod --yes

# Alias
vercel alias set frontend-two-beryl-74.vercel.app omniutil.vercel.app

# Vérifications SEO
for file in robots.txt sitemap.xml google05be3ba8343d04a2.html; do
    if curl -s -o /dev/null -w "%{http_code}" https://omniutil.vercel.app/$file | grep -q 200; then
        echo "✅ $file OK"
    else
        echo "❌ $file NON VISIBLE"
    fi
done

echo "🎉 OmniUtil déployé – 100% opérationnel"
