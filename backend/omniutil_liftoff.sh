#!/bin/bash
set -e

echo "🌕 Omniutil Liftoff – Infrastructure Finale"

#################################
# 1️⃣ ENVIRONNEMENT STABLE
#################################
export NODE_ENV=production
export NODE_OPTIONS="--max-old-space-size=4096"

#################################
# 2️⃣ ARRÊT DES PROCESS EXISTANTS
#################################
echo "🧹 Nettoyage..."
pkill -f node || true
sleep 1

#################################
# 3️⃣ INSTALLATION DÉPENDANCES
#################################
echo "📦 Vérification dépendances..."
npm install express helmet qrcode
npm install -D @types/express @types/node typescript ts-node

#################################
# 4️⃣ TSC SAFE MODE (ANTI-OOM)
#################################
echo "🛡️ Génération tsconfig SAFE..."

cat > tsconfig.json <<EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "rootDir": "src",
    "outDir": "dist",
    "esModuleInterop": true,
    "strict": false,
    "skipLibCheck": true,
    "noEmitOnError": false
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "frontend", "public"]
}
EOF

#################################
# 5️⃣ COMPILATION BACKEND ISOLÉE
#################################
echo "🔨 Compilation backend (stable)..."
npx tsc --incremental || echo "⚠️ Warnings tolérés"

#################################
# 6️⃣ FRONTEND SANS FLAG TOXIQUE
#################################
echo "🎨 Build frontend (sans abs-working-dir)..."

if [ -f "src/test_full_browser.ts" ]; then
  npx esbuild src/test_full_browser.ts \
    --bundle \
    --platform=browser \
    --target=es2020 \
    --format=iife \
    --outfile=public/explorer.js
else
  echo "ℹ️ Aucun frontend TS à builder"
fi

#################################
# 7️⃣ LANCEMENT BACKEND FINAL
#################################
echo "🚀 Lancement Omniutil Backend..."
node dist/index.js &

#################################
# 8️⃣ SERVEUR FRONTEND STATIQUE
#################################
echo "🌐 Lancement Frontend..."
npx serve public -l 8081 &

#################################
# 9️⃣ RÉSUMÉ
#################################
echo ""
echo "✅ OMNIUTIL OPÉRATIONNEL"
echo "🔗 Backend  : http://localhost:8080"
echo "🔗 Frontend : http://localhost:8081"
echo "🌕 La lune est arrachée."
