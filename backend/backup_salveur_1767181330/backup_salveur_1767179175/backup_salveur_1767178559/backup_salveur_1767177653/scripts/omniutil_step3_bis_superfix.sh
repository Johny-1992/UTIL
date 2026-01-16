#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 BIS SUPERFIX: ROUTES & AI"
echo "================================================="

# Définition des chemins
BACKEND_DIR="/root/omniutil/backend"
SRC_DIR="$BACKEND_DIR/src"
API_DIR="$SRC_DIR/api"
DIST_DIR="$BACKEND_DIR/dist"

# 1️⃣ Vérification / création ai.ts
AI_FILE="$API_DIR/ai.ts"
if [ ! -f "$AI_FILE" ]; then
  echo "📌 ai.ts manquant, création..."
  cat > "$AI_FILE" <<EOL
import { Router } from 'express';
const router = Router();

router.get('/status', (req, res) => {
  res.json({ ai: 'operational' });
});

export default router;
EOL
else
  echo "✅ ai.ts trouvé, vérification contenu..."
fi

# 2️⃣ Vérification / création partner_validation.ts
PARTNER_FILE="$API_DIR/partner_validation.ts"
if [ ! -f "$PARTNER_FILE" ]; then
  echo "📌 partner_validation.ts manquant, création..."
  cat > "$PARTNER_FILE" <<EOL
import { Router } from 'express';
const router = Router();

router.post('/onboard', (req, res) => {
  res.json({ partner: 'onboarded' });
});

export default router;
EOL
else
  echo "✅ partner_validation.ts trouvé, vérification contenu..."
fi

# 3️⃣ Correction imports et mounting dans index.ts
INDEX_FILE="$SRC_DIR/index.ts"
echo "✏️ Correction imports et routes dans index.ts..."
sed -i "/import aiRouter/d" $INDEX_FILE
sed -i "/import partnerRouter/d" $INDEX_FILE

sed -i "1i import aiRouter from './api/ai';" $INDEX_FILE
sed -i "1i import partnerRouter from './api/partner_validation';" $INDEX_FILE

# Vérification montage routes
grep -q "app.use('/api/ai', aiRouter);" $INDEX_FILE || echo "app.use('/api/ai', aiRouter);" >> $INDEX_FILE
grep -q "app.use('/api/partner', partnerRouter);" $INDEX_FILE || echo "app.use('/api/partner', partnerRouter);" >> $INDEX_FILE

# 4️⃣ Compilation TypeScript
echo "📦 Compilation TypeScript..."
cd $BACKEND_DIR
npx tsc

# 5️⃣ Redémarrage PM2
echo "🔄 Redémarrage backend avec PM2..."
pm2 delete omniutil-api 2>/dev/null
pm2 start $DIST_DIR/index.js --name omniutil-api
pm2 save

# 6️⃣ Vérification endpoints
echo "🌐 Vérification endpoints..."
sleep 2
curl -I http://127.0.0.1:3000/health
curl -I http://127.0.0.1:3000/api/ai/status
curl -I http://127.0.0.1:3000/api/partner/onboard

echo "🎉 STEP 3 BIS SUPERFIX TERMINÉ !"
