#!/bin/bash
echo "🚀 OMNIUTIL — STEP 2: QR UNIVERSEL & ONBOARDING PARTENAIRES"
echo "============================================================"

# 📁 Vérification des dossiers
BACKEND_DIR="/root/omniutil/backend"
FRONTEND_DIR="/root/omniutil/frontend"
SCRIPTS_DIR="$BACKEND_DIR/scripts"

echo "📌 Backend : $BACKEND_DIR"
echo "📌 Frontend : $FRONTEND_DIR"

# 🔧 Création des dossiers QR et onboarding si inexistants
mkdir -p $BACKEND_DIR/src/qr
mkdir -p $BACKEND_DIR/src/onboarding

# 🧾 Création QR universel
QR_FILE="$BACKEND_DIR/src/qr/omniutil_qr.ts"
cat > $QR_FILE <<EOL
import QRCode from 'qrcode';

export async function generateOmniutilQR(partnerId: string) {
    const url = \`https://omniutil.com/onboard?partner=\${partnerId}\`;
    try {
        return await QRCode.toDataURL(url);
    } catch (err) {
        console.error('Erreur génération QR:', err);
        return null;
    }
}
EOL
echo "✅ omniutil_qr.ts créé"

# 🤝 Création onboarding partenaire automatique
ONBOARD_FILE="$BACKEND_DIR/src/onboarding/partner_auto.ts"
cat > $ONBOARD_FILE <<EOL
import { Router } from 'express';
import { generateOmniutilQR } from '../qr/omniutil_qr';

const router = Router();

router.post('/onboard', async (req, res) => {
    const { partner_id } = req.body;
    if (!partner_id) return res.status(400).json({ error: 'partner_id manquant' });

    const qr = await generateOmniutilQR(partner_id);
    res.json({
        message: \`Partenaire \${partner_id} onboardé avec succès!\`,
        qr
    });
});

export default router;
EOL
echo "✅ partner_auto.ts créé"

# 🔌 Ajout route auto onboarding dans index.ts
INDEX_FILE="$BACKEND_DIR/src/index.ts"
grep -q "partner_auto" $INDEX_FILE || sed -i "/import .*router.*/a import partnerAutoRoutes from './onboarding/partner_auto';\napp.use('/api/partner', partnerAutoRoutes);" $INDEX_FILE
echo "✅ Route onboarding ajoutée dans index.ts"

# 📦 Compilation TypeScript
cd $BACKEND_DIR
echo "📦 Compilation TypeScript..."
npx tsc

# 🔄 Redémarrage PM2
echo "🔄 Redémarrage PM2..."
pm2 restart omniutil-api || pm2 start dist/index.js --name omniutil-api

# 🧪 Test API onboarding
echo "🧪 Test endpoint POST /api/partner/onboard"
curl -s -X POST http://127.0.0.1:3000/api/partner/onboard -H "Content-Type: application/json" -d '{"partner_id":"TEST123"}' | jq

echo "🎉 OMNIUTIL STEP 2 TERMINÉ !"
echo "QR universel et onboarding automatique partenaires prêts."
