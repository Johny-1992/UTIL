#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL ABSOLU: ROUTES & AI"
echo "================================================="

BACKEND_DIR="/root/omniutil/backend"
SRC_API="$BACKEND_DIR/src/api"
DIST="$BACKEND_DIR/dist"

# 1️⃣ Vérification fichiers essentiels
for f in ai.ts partner_validation.ts; do
    if [[ -f "$SRC_API/$f" ]]; then
        echo "✅ $f trouvé."
    else
        echo "❌ $f manquant !"
        exit 1
    fi
done

# 2️⃣ Correction et ajout des routes dans partner_validation.ts si manquantes
if ! grep -q "router.post('/onboard'" "$SRC_API/partner_validation.ts"; then
    echo "✏️ Ajout route /onboard dans partner_validation.ts..."
    echo -e "\nrouter.post('/onboard', (req, res) => res.json({ message: 'Partner onboarded' }));" >> "$SRC_API/partner_validation.ts"
fi

# 3️⃣ Correction index.ts
INDEX_FILE="$BACKEND_DIR/src/index.ts"
echo "✏️ Correction imports et registration des routers dans index.ts..."
cat > "$INDEX_FILE" <<EOL
import express from 'express';
import aiRouter from './api/ai';
import partnerRouter from './api/partner_validation';

const app = express();
app.use(express.json());

app.use('/api/ai', aiRouter);
app.use('/api/partner', partnerRouter);

app.get('/health', (req, res) => res.json({ status: 'OK' }));

const PORT = 3000;
app.listen(PORT, () => console.log(\`🚀 OMNIUTIL API running on port \${PORT}\`));

export default app;
EOL

# 4️⃣ Suppression dist/ pour compilation propre
echo "📦 Suppression $DIST..."
rm -rf "$DIST"

# 5️⃣ Installation dépendances
echo "📦 Vérification et installation dépendances..."
npm install

# 6️⃣ Compilation TypeScript
echo "📦 Compilation TypeScript..."
npx tsc

# 7️⃣ Redémarrage PM2
echo "🔄 Redémarrage backend avec PM2..."
pm2 delete omniutil-api 2>/dev/null
pm2 start "$DIST/index.js" --name omniutil-api
pm2 save

# 8️⃣ Vérification endpoints
echo "🌐 Vérification endpoints..."
for endpoint in "/health" "/api/ai/status" "/api/partner/onboard"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:3000$endpoint")
    if [[ "$STATUS" == "200" ]]; then
        echo "$endpoint → HTTP $STATUS ✅"
    else
        echo "$endpoint → HTTP $STATUS ❌"
    fi
done

echo "🎉 STEP 3 FINAL ABSOLU TERMINÉ !"
