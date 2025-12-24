#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="/root/omniutil/backend"
PM2_NAME="omniutil-api"

echo "[step8] Configuration de l'API métier (backend/api) dans l'app Express principale"
cd "$BACKEND_DIR"
echo "[step8] Dossier backend : $(pwd)"

# 1) Backups de sécurité
if [ -f "index.ts" ] && [ ! -f "index.ts.step8.bak" ]; then
  cp index.ts index.ts.step8.bak
  echo "[step8] Backup créé : index.ts.step8.bak"
fi

if [ -f "api/index.ts" ] && [ ! -f "api/index.ts.step8.bak" ]; then
  cp api/index.ts api/index.ts.step8.bak
  echo "[step8] Backup créé : api/index.ts.step8.bak"
fi

# 2) Réécriture de backend/api/index.ts en Router Express
mkdir -p api

cat <<'EOF_API' > api/index.ts
import { Router, Request, Response } from 'express';
import { onboardPartner } from './partner.onboard';
import { computeUTIL } from './reward.compute';
import { exchangeUTIL } from './util.exchange';

const router = Router();

// POST /api/partner/onboard
router.post('/partner/onboard', (req: Request, res: Response) => {
  const partner = req.body;
  try {
    const result = onboardPartner(partner);
    return res.json(result);
  } catch (err) {
    console.error('Erreur dans onboardPartner:', err);
    return res.status(500).json({
      error: 'Erreur interne lors de l’onboarding partenaire',
    });
  }
});

// POST /api/reward/compute
router.post('/reward/compute', (req: Request, res: Response) => {
  const { usage, rate } = req.body;

  if (typeof usage !== 'number' || typeof rate !== 'number') {
    return res.status(400).json({
      error: 'Paramètres invalides',
      details: 'usage et rate doivent être des nombres',
    });
  }

  try {
    const util = computeUTIL(usage, rate);
    return res.json({ usage, rate, util });
  } catch (err) {
    console.error('Erreur dans computeUTIL:', err);
    return res.status(500).json({
      error: 'Erreur interne lors du calcul UTIL',
    });
  }
});

// POST /api/util/exchange
router.post('/util/exchange', (req: Request, res: Response) => {
  const { user, service, amount } = req.body;

  if (typeof user !== 'string' || typeof service !== 'string' || typeof amount !== 'number') {
    return res.status(400).json({
      error: 'Paramètres invalides',
      details: 'user et service doivent être des chaînes, amount un nombre',
    });
  }

  try {
    const result = exchangeUTIL(user, service, amount);
    return res.json(result);
  } catch (err) {
    console.error('Erreur dans exchangeUTIL:', err);
    return res.status(500).json({
      error: 'Erreur interne lors de l’échange UTIL',
    });
  }
});

export default router;
EOF_API

echo "[step8] api/index.ts transformé en Router Express."

# 3) Réécriture contrôlée de index.ts pour monter le router /api
cat <<'EOF_IDX' > index.ts
import 'dotenv/config';
import express, { Request, Response } from 'express';
import partnerValidation from './partner_validation';
import aiRouter from './ai';
import apiRouter from './api';
import { apiKeyAuth } from './src/middleware/apiKeyAuth';
import { requestLogger } from './src/middleware/logger';
import { rateLimiter } from './src/middleware/rateLimit';

const app = express();

// PORT configuré via .env ou 3000 par défaut
const PORT: number = Number(process.env.PORT) || 3000;

// Faire confiance au proxy (Nginx) pour les IP / X-Forwarded-For
app.set('trust proxy', true);

// Middleware global JSON + logger
app.use(express.json());
app.use(requestLogger);

// Route de santé publique (sans auth, sans rate limit)
app.get('/health', (_req: Request, res: Response) => {
  return res.status(200).json({ status: 'ok' });
});

// À partir d'ici : rate limit + clé API
app.use(rateLimiter);
app.use(apiKeyAuth);

// Ancienne logique /api/partner (valideur)
app.use('/api/partner', partnerValidation);

// AI coordonnateur
app.use('/api/ai', aiRouter);

// Nouvelle API métier OMNIUTIL (onboard, reward, util)
app.use('/api', apiRouter);

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
EOF_IDX

echo "[step8] index.ts mis à jour pour monter /api."

# 4) Compilation + redémarrage PM2
echo "[step8] Compilation TypeScript..."
npx tsc

echo "[step8] (Re)lancement de l'API avec PM2..."
if pm2 describe "$PM2_NAME" >/dev/null 2>&1; then
  pm2 restart "$PM2_NAME" --update-env
else
  pm2 start dist/index.js --name "$PM2_NAME"
fi

pm2 save

echo "============================================================"
echo "[step8] Terminé. Tests recommandés :"
echo "1) cd /root/omniutil/backend"
echo "2) API_KEY=\$(grep '^API_KEY' .env | cut -d= -f2-)"
echo "3) curl -k https://127.0.0.1:8443/api/reward/compute \\"
echo "      -H \"x-api-key: \$API_KEY\" -H 'Content-Type: application/json' \\"
echo "      -d '{\"usage\": 100, \"rate\": 1.5}'"
echo "4) curl -k https://127.0.0.1:8443/api/partner/onboard \\"
echo "      -H \"x-api-key: \$API_KEY\" -H 'Content-Type: application/json' \\"
echo "      -d '{\"name\":\"Test\",\"score\": 90}'"
echo "5) curl -k https://127.0.0.1:8443/api/util/exchange \\"
echo "      -H \"x-api-key: \$API_KEY\" -H 'Content-Type: application/json' \\"
echo "      -d '{\"user\":\"alice\",\"service\":\"hotel\",\"amount\": 50}'"
echo "============================================================"
