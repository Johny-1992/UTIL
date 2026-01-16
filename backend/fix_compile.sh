#!/bin/bash
set -e

echo "🔹 Nettoyage anciens builds…"
kill $(lsof -ti :8080) 2>/dev/null || true
kill $(lsof -ti :8081) 2>/dev/null || true
rm -rf dist public/explorer.js

echo "📦 Compilation TypeScript backend…"
npx tsc

echo "🛠 Correction frontend TypeScript…"
# Remplace fn.name par string par défaut
sed -i 's/tdName.textContent = fn.name;/tdName.textContent = fn.name ?? "";/g' src/test_full_browser.ts
sed -i 's/const res = await (contract as any)\[fn.name\]();/const res = await (contract as any)\[fn.name ?? ""\]();/g' src/test_full_browser.ts

echo "📦 Compilation frontend sécurisé…"
mkdir -p public
npx esbuild src/test_full_browser.ts \
  --bundle \
  --platform=browser \
  --target=es2020 \
  --format=iife \
  --outfile=public/explorer.js

echo "🚀 Démarrage backend et frontend…"
# Lancer le serveur comme start_all_live.sh
./start_all_live.sh
