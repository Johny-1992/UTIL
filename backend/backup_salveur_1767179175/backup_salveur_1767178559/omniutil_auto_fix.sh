#!/bin/bash
set -e

echo "📦 1/6 : Compilation TypeScript..."
npx tsc

echo "🔍 2/6 : Détection des fichiers de routes dans src/api..."
API_DIR="./src/api"
INDEX_FILE="./src/index.ts"

# Créer index.ts si inexistant
if [ ! -f "$INDEX_FILE" ]; then
  echo "import express from 'express';" > "$INDEX_FILE"
  echo "const app = express();" >> "$INDEX_FILE"
fi

# Commencer index.ts
echo "import express from 'express';" > "$INDEX_FILE"
echo "const app = express();" >> "$INDEX_FILE"
echo "app.use(express.json());" >> "$INDEX_FILE"

# Ajouter les routes dynamiquement
for f in "$API_DIR"/*.ts; do
  route_name=$(basename "$f" .ts)
  if [ "$route_name" != "index" ]; then
    echo "import ${route_name}Router from './api/${route_name}';" >> "$INDEX_FILE"
    echo "app.use('/api/${route_name}', ${route_name}Router);" >> "$INDEX_FILE"
  fi
done

# Routes de base
echo "app.get('/health', (_req, res) => res.json({ status: 'ok' }));" >> "$INDEX_FILE"
echo "app.get('/api/index', (_req, res) => res.json({ message: 'API fonctionnelle !' }));" >> "$INDEX_FILE"

# Export app
echo "export default app;" >> "$INDEX_FILE"

echo "🔄 3/6 : Redémarrage de PM2..."
pm2 restart omniutil-api || pm2 start dist/index.js --name omniutil-api --watch
pm2 save

echo "🧪 4/6 : Test des endpoints..."
ENDPOINTS=("GET /health" "GET /api/index")
for ep in "${ENDPOINTS[@]}"; do
  method=$(echo $ep | cut -d' ' -f1)
  path=$(echo $ep | cut -d' ' -f2)
  status=$(curl -s -o /dev/null -w "%{http_code}" -X $method http://127.0.0.1:3000$path)
  echo "$method $path Status: $status"
done

echo "✅ 5/6 : Test POST (vérifier si fichiers existent)..."
POST_ENDPOINTS=("partner/onboard" "ai/test")
for ep in "${POST_ENDPOINTS[@]}"; do
  if [ -f "$API_DIR/${ep%%/*}.ts" ]; then
    status=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d '{"test":1}' http://127.0.0.1:3000/api/$ep)
    echo "POST /api/$ep Status: $status"
  else
    echo "POST /api/$ep ❌ Fichier source absent"
  fi
done

echo "🎉 6/6 : Script terminé. Vérifie les logs PM2 pour plus de détails :"
echo "tail -f /root/.pm2/logs/omniutil-api-out.log"
