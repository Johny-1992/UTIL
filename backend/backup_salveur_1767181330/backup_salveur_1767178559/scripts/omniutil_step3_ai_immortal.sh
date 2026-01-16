#!/bin/bash
# 🚀 OMNIUTIL — STEP 3: AI COORDINATOR & IMMORTALIZATION
# Path: /root/omniutil/backend/scripts/omniutil_step3_ai_immortal.sh

echo "🚀 OMNIUTIL — STEP 3: AI COORDINATOR & IMMORTALIZATION"
echo "====================================================="

BACKEND_DIR="/root/omniutil/backend"
FRONTEND_DIR="/root/omniutil/frontend"

echo "📌 Backend : $BACKEND_DIR"
echo "📌 Frontend : $FRONTEND_DIR"

# Step 1: Création du module AI centralisé
AI_FILE="$BACKEND_DIR/src/ai/ai_coordinator.ts"
mkdir -p "$(dirname "$AI_FILE")"
cat > "$AI_FILE" <<EOL
import { Router } from 'express';
const router = Router();

// Endpoint test AI Coordinator
router.get('/ai/status', (req, res) => {
    res.json({ status: 'AI Coordinator operational', timestamp: new Date() });
});

// TODO: Ajouter la logique AI centrale ici
export default router;
EOL
echo "✅ ai_coordinator.ts créé"

# Step 2: Intégration AI dans index.ts
INDEX_FILE="$BACKEND_DIR/src/index.ts"
grep -q "ai_coordinator" "$INDEX_FILE" || sed -i "/import partnerRoutes from '.\/api\/partner_validation';/a import aiCoordinator from './ai/ai_coordinator';" "$INDEX_FILE"
grep -q "aiCoordinator" "$INDEX_FILE" || sed -i "/app.use('/api', partnerRoutes);/a app.use('/api', aiCoordinator);" "$INDEX_FILE"
echo "✅ AI Coordinator intégré dans index.ts"

# Step 3: Compilation TypeScript
echo "📦 Compilation TypeScript..."
cd "$BACKEND_DIR"
npx tsc
if [ $? -eq 0 ]; then
    echo "✅ Compilation terminée"
else
    echo "❌ Erreurs de compilation, vérifier logs"
    exit 1
fi

# Step 4: Immortalisation PM2
echo "🔄 Immortalisation backend avec PM2..."
pm2 delete omniutil-api > /dev/null 2>&1
pm2 start dist/index.js --name omniutil-api --watch
pm2 save
echo "✅ PM2 backend immortalisé et sauvegardé"

# Step 5: Vérification backend
echo "🔍 Vérification backend..."
curl -s http://127.0.0.1:3000/health | grep -q 'ok' && echo "✅ Backend répond" || echo "⚠️ Backend KO"

# Step 6: Test AI endpoint
echo "🧪 Test AI Coordinator endpoint..."
curl -s http://127.0.0.1:3000/api/ai/status

echo "🎉 OMNIUTIL STEP 3 TERMINÉ !"
