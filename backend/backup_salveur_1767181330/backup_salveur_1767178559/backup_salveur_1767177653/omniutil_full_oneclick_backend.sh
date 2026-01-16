#!/bin/bash
set -e

echo "🚀 OMNIUTIL FULL ONE-CLICK BACKEND LAUNCHER"

# 1️⃣ Compilation TypeScript
echo "📦 1/5 : Compilation TypeScript..."
npx tsc
echo "✅ Compilation terminée."

# 2️⃣ Redémarrage du backend via PM2
echo "🔄 2/5 : Redémarrage backend PM2..."
pm2 restart omniutil-api --update-env || pm2 start dist/index.js --name omniutil-api
pm2 save
echo "✅ Backend relancé."

# 3️⃣ Vérification santé du backend
echo "🌐 3/5 : Test santé API..."
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/health)
if [ "$HEALTH" -eq 200 ]; then
    echo "✅ API répond sur http://127.0.0.1:3000/health"
else
    echo "❌ API ne répond pas (code $HEALTH)"
fi

# 4️⃣ Détection des endpoints
echo "🔍 4/5 : Détection automatique des endpoints..."
ENDPOINTS=$(node -e "
const app = require('./dist/index').default || require('./dist/index');
if (!app._router) { console.log('Aucune route détectée'); process.exit(0); }
app._router.stack.filter(r => r.route).forEach(r => {
  const methods = Object.keys(r.route.methods).join(',').toUpperCase();
  console.log(\`\${methods} \${r.route.path}\`);
});
")
echo "$ENDPOINTS"

# 5️⃣ Test automatique des endpoints GET/POST
echo "🧪 5/5 : Test automatique des endpoints..."
while read -r line; do
    METHOD=$(echo "$line" | awk '{print $1}')
    PATH=$(echo "$line" | awk '{print $2}')
    if [ "$METHOD" == "GET" ]; then
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:3000$PATH")
        echo "GET $PATH -> Status: $STATUS"
    elif [ "$METHOD" == "POST" ]; then
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
            -H "Content-Type: application/json" \
            -d '{"test":"ok"}' "http://127.0.0.1:3000$PATH")
        echo "POST $PATH -> Status: $STATUS"
    fi
done <<< "$ENDPOINTS"

echo "🎉 ONE-CLICK BACKEND OMNIUTIL TERMINÉ !"
