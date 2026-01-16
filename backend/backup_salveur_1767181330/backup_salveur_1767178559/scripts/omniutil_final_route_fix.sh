#!/bin/bash
set -e

echo "================================================="
echo "🚀 OMNIUTIL — FINAL ROUTE FIX SCRIPT"
echo "================================================="

BASE_DIR="/root/omniutil/backend"
DIST_DIR="$BASE_DIR/dist"
SRC_API="$BASE_DIR/src/api"

# 1️⃣ Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
for file in ai.ts partner_validation.ts; do
    if [ ! -f "$SRC_API/$file" ]; then
        echo "❌ Fichier $file manquant !"
        exit 1
    fi
    echo "✅ $file trouvé."
done

# 2️⃣ Écriture router minimal partner_validation.ts
echo "✏️ Mise à jour partner_validation.ts..."
cat > "$SRC_API/partner_validation.ts" << 'EOF'
import { Router } from 'express';
const router = Router();

// Endpoint onboard
router.get('/onboard', (req, res) => {
  res.json({ status: 'ok', message: 'Partner onboard endpoint works!' });
});

export default router;
EOF

# 3️⃣ Écriture router minimal ai.ts
echo "✏️ Mise à jour ai.ts..."
cat > "$SRC_API/ai.ts" << 'EOF'
import { Router } from 'express';
const router = Router();

router.get('/status', (req, res) => {
  res.json({ status: 'ok', message: 'AI Coordinator endpoint works!' });
});

export default router;
EOF

# 4️⃣ Mise à jour index.ts pour importer et utiliser les routers
echo "✏️ Correction index.ts..."
cat > "$BASE_DIR/src/index.ts" << 'EOF'
import express from 'express';
import partnerValidationRouter from './api/partner_validation';
import aiRouter from './api/ai';

const app = express();
const PORT = process.env.PORT || 3000;

app.use('/api/partner', partnerValidationRouter);
app.use('/api/ai', aiRouter);

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, () => console.log(`🚀 OMNIUTIL API running on port ${PORT}`));
EOF

# 5️⃣ Suppression dist pour compilation propre
echo "📦 Suppression dist/..."
rm -rf "$DIST_DIR"

# 6️⃣ Installation dépendances et compilation
echo "📦 Installation dépendances et compilation TypeScript..."
cd "$BASE_DIR"
npm install
npx tsc

# 7️⃣ Redémarrage PM2
echo "🔄 Redémarrage backend avec PM2..."
pm2 delete omniutil-api || true
pm2 start "$DIST_DIR/index.js" --name omniutil-api
pm2 save

# 8️⃣ Vérification endpoints
echo "🌐 Vérification endpoints..."
curl -I http://127.0.0.1:3000/health
curl -I http://127.0.0.1:3000/api/partner/onboard
curl -I http://127.0.0.1:3000/api/ai/status

echo "🎉 SCRIPT FINAL ROUTES COMPLET !"
