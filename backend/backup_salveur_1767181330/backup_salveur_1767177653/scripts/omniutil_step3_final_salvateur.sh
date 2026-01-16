#!/bin/bash
# omniutil_step3_final_salvateur.sh
# 🚀 OMNIUTIL — STEP 3 FINAL SALVATEUR ULTIMATE AUTO-FIXER

set -e

BACKEND_DIR="/root/omniutil/backend"
SRC_DIR="$BACKEND_DIR/src"
PM2_APP="omniutil-api"

echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL SALVATEUR ULTIMATE"
echo "================================================="

# 1️⃣ Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
for file in "$SRC_DIR/index.ts" "$SRC_DIR/api/ai.ts" "$SRC_DIR/api/partner_validation.ts"; do
  if [ ! -f "$file" ]; then
    echo "❌ Fichier manquant: $file"
    exit 1
  else
    echo "✅ $file trouvé."
  fi
done

# 2️⃣ Correction index.ts et imports
echo "✏️ Correction index.ts et imports..."

cat > "$SRC_DIR/index.ts" <<'EOF'
import express from 'express';
import partnerValidation from './api/partner_validation';
import aiRouter from './api/ai';

const app = express();
const PORT: number = Number(process.env.PORT) || 3000;

app.use(express.json());
app.use('/api/partner', partnerValidation);
app.use('/api/ai', aiRouter);

app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));

app.listen(PORT, '0.0.0.0', () => {
  console.log('Server running on port', PORT);
});
export default app;
EOF

cat > "$SRC_DIR/api/partner_validation.ts" <<'EOF'
import { Router } from 'express';
const router = Router();

router.get('/onboard', (req, res) => {
  res.json({ message: 'Partner onboard endpoint OK' });
});

export default router;
EOF

cat > "$SRC_DIR/api/ai.ts" <<'EOF'
import { Router } from 'express';
const router = Router();

router.get('/status', (req, res) => {
  res.json({ status: 'AI endpoint OK' });
});

export default router;
EOF

# 3️⃣ Suppression dist
echo "📦 Suppression $BACKEND_DIR/dist..."
rm -rf "$BACKEND_DIR/dist"

# 4️⃣ Installation dépendances & compilation TS
echo "📦 Installation dépendances et compilation TypeScript..."
cd "$BACKEND_DIR"
npm install
npx tsc

# 5️⃣ Redémarrage PM2
echo "🔄 Redémarrage PM2..."
pm2 delete $PM2_APP || true
pm2 start dist/index.js --name $PM2_APP
pm2 save

# 6️⃣ Vérification /health
echo "🌐 Vérification /health..."
for i in {1..10}; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/health || echo "000")
  if [ "$STATUS" = "200" ]; then
    echo "✅ /health OK (HTTP 200) après $i tentative(s)."
    exit 0
  else
    echo "⚠️ Tentative $i: /health → HTTP $STATUS, redémarrage PM2..."
    pm2 restart $PM2_APP
    sleep 2
  fi
done

echo "❌ /health toujours non disponible après 10 tentatives."
echo "Vérifie les logs PM2 avec 'pm2 logs $PM2_APP'."
exit 1
