#!/bin/bash
set -e

BACKEND_DIR="/root/omniutil/backend"
SRC_DIR="$BACKEND_DIR/src"
API_DIR="$SRC_DIR/api"
DIST_DIR="$BACKEND_DIR/dist"
PM2_APP="omniutil-api"

echo "🚀 OMNIUTIL FULL AUTO-FIX SCRIPT"

# 1️⃣ Création des fichiers API si manquants ou correction
echo "📦 1/6 : Vérification et création des routes API..."

mkdir -p "$API_DIR"

# Partner validation
cat > "$API_DIR/partner_validation.ts" << 'EOF'
import { Router } from 'express';
const router = Router();

router.post('/onboard', (req, res) => {
  const { user_id } = req.body;
  if (!user_id) return res.status(400).json({ error: 'user_id manquant' });
  res.json({ message: `Utilisateur ${user_id} onboardé !` });
});

export default router;
EOF

# Fraud detection / AI test
cat > "$API_DIR/fraud_detection.ts" << 'EOF'
import { Router } from 'express';
const router = Router();

router.post('/test', (req, res) => {
  const { test } = req.body;
  if (!test) return res.status(400).json({ error: 'Paramètre manquant' });
  res.json({ message: `Test IA reçu : ${test}` });
});

export default router;
EOF

echo "✅ Routes API créées ou corrigées."

# 2️⃣ Correction du fichier index.ts
echo "📦 2/6 : Correction de src/index.ts..."
cat > "$SRC_DIR/index.ts" << 'EOF'
import express from 'express';
import bodyParser from 'body-parser';

import partnerRoutes from './api/partner_validation';
import aiRoutes from './api/fraud_detection';

const app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Monte les routes
app.use('/api/partner', partnerRoutes);
app.use('/api/ai', aiRoutes);

// Endpoints GET de test
app.get('/health', (_req, res) => res.json({ status: 'ok' }));
app.get('/api/index', (_req, res) => res.json({ message: 'API fonctionnelle !' }));

if (require.main === module) {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`🚀 OMNIUTIL API running on port ${PORT}`);
  });
}

export default app;
EOF
echo "✅ src/index.ts corrigé."

# 3️⃣ Compilation TypeScript
echo "📦 3/6 : Compilation TypeScript..."
cd "$BACKEND_DIR"
npx tsc
echo "✅ Compilation terminée."

# 4️⃣ Redémarrage PM2
echo "🔄 4/6 : Redémarrage PM2..."
pm2 restart "$PM2_APP" --update-env || pm2 start "$DIST_DIR/index.js" --name "$PM2_APP"
pm2 save
echo "✅ PM2 relancé."

# 5️⃣ Test automatique des endpoints
echo "🧪 5/6 : Test des endpoints..."

echo "GET /health"
curl -s http://127.0.0.1:3000/health && echo -e "\n"

echo "GET /api/index"
curl -s http://127.0.0.1:3000/api/index && echo -e "\n"

echo "POST /api/partner/onboard"
curl -s -X POST http://127.0.0.1:3000/api/partner/onboard \
     -H "Content-Type: application/json" \
     -d '{"user_id":"123"}' && echo -e "\n"

echo "POST /api/ai/test"
curl -s -X POST http://127.0.0.1:3000/api/ai/test \
     -H "Content-Type: application/json" \
     -d '{"test":"ok"}' && echo -e "\n"

echo "🎉 OMNIUTIL AUTO-FIX COMPLET TERMINÉ !"
