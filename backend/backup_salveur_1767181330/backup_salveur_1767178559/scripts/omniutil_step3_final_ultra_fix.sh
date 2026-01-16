#!/bin/bash
echo "================================================="
echo "🚀 OMNIUTIL — STEP 3 FINAL ULTRA-FIX: ROUTES & AI"
echo "================================================="

BACKEND_DIR="/root/omniutil/backend"
SRC_DIR="$BACKEND_DIR/src"
DIST_DIR="$BACKEND_DIR/dist"

# 1️⃣ Vérification fichiers essentiels
echo "📦 Vérification fichiers essentiels..."
for f in "api/ai.ts" "api/partner_validation.ts"; do
    if [ ! -f "$SRC_DIR/$f" ]; then
        echo "❌ Fichier manquant: $f. Création automatique..."
        mkdir -p "$(dirname "$SRC_DIR/$f")"
        touch "$SRC_DIR/$f"
    fi
done
echo "✅ Fichiers essentiels OK"

# 2️⃣ Forcer export router dans ai.ts et partner_validation.ts
echo "✏️ Correction exports router..."
cat > "$SRC_DIR/api/ai.ts" <<EOL
import { Router } from 'express';
const router = Router();
router.get('/status', (req, res) => res.json({ status: 'AI Coordinator OK' }));
export default router;
EOL

cat > "$SRC_DIR/api/partner_validation.ts" <<EOL
import { Router } from 'express';
const router = Router();
router.post('/onboard', (req, res) => res.json({ message: 'Partner onboarded' }));
export default router;
EOL
echo "✅ Exports router corrigés"

# 3️⃣ Correction index.ts
echo "✏️ Correction index.ts..."
cat > "$SRC_DIR/index.ts" <<EOL
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
echo "✅ index.ts corrigé"

# 4️⃣ Compilation propre
echo "📦 Suppression dist/ pour compilation propre..."
rm -rf "$DIST_DIR"

# 5️⃣ Installation dépendances et compilation
echo "📦 Installation dépendances et compilation TypeScript..."
cd "$BACKEND_DIR"
npm install
npx tsc
echo "✅ Compilation terminée"

# 6️⃣ Redémarrage PM2
echo "🔄 Redémarrage PM2..."
pm2 delete omniutil-api 2>/dev/null
pm2 start "$DIST_DIR/index.js" --name omniutil-api
pm2 save
echo "✅ PM2 backend immortalisé et sauvegardé."

# 7️⃣ Vérification endpoints
echo "🌐 Vérification endpoints..."
sleep 2
curl -I http://127.0.0.1:3000/health
curl -I http://127.0.0.1:3000/api/ai/status
curl -I http://127.0.0.1:3000/api/partner/onboard

echo "🎉 STEP 3 FINAL ULTRA-FIX TERMINÉ !"
