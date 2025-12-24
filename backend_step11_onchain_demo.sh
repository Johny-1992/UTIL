#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="/root/omniutil/backend"
LEDGER_JSON="$BACKEND_DIR/onchain_demo_ledger.json"
PM2_NAME="omniutil-api"

echo "[step11] Configuration de la couche onchain DEMO (ledger JSON) pour OMNIUTIL"
cd "$BACKEND_DIR"
echo "[step11] Dossier backend : $(pwd)"

# 1) Backups de sécurité
for f in ai.ts services/sync_chain.ts src/onchain/ledger.ts; do
  if [ -f "$f" ] && [ ! -f "$f.step11.bak" ]; then
    cp "$f" "$f.step11.bak"
    echo "[step11] Backup créé : $f.step11.bak"
  fi
done

mkdir -p src/onchain
mkdir -p services

# 2) Création du ledger JSON initial (si absent)
if [ ! -f "$LEDGER_JSON" ]; then
  now=$(date -Iseconds || date)
  cat > "$LEDGER_JSON" <<EOF_LEDGER
{
  "util": {
    "balances": {}
  },
  "partners": {},
  "meta": {
    "mode": "demo",
    "createdAt": "$now",
    "updatedAt": "$now"
  }
}
EOF_LEDGER
  echo "[step11] Ledger DEMO créé : $LEDGER_JSON"
else
  echo "[step11] Ledger DEMO déjà présent : $LEDGER_JSON"
fi

# 3) Module TypeScript : src/onchain/ledger.ts
cat <<'EOF_LEDGER_TS' > src/onchain/ledger.ts
import fs from 'fs';
import path from 'path';

export const LEDGER_PATH = path.join(process.cwd(), 'onchain_demo_ledger.json');

export interface OnchainDemoLedger {
  util: {
    balances: Record<string, number>;
  };
  partners: Record<string, any>;
  meta: {
    mode: string;
    createdAt: string;
    updatedAt: string;
  };
}

function createDefaultLedger(): OnchainDemoLedger {
  const now = new Date().toISOString();
  const ledger: OnchainDemoLedger = {
    util: { balances: {} },
    partners: {},
    meta: {
      mode: 'demo',
      createdAt: now,
      updatedAt: now,
    },
  };
  fs.writeFileSync(LEDGER_PATH, JSON.stringify(ledger, null, 2), 'utf-8');
  return ledger;
}

export function loadLedger(): OnchainDemoLedger {
  try {
    if (!fs.existsSync(LEDGER_PATH)) {
      return createDefaultLedger();
    }
    const content = fs.readFileSync(LEDGER_PATH, 'utf-8');
    const parsed = JSON.parse(content) as OnchainDemoLedger;
    if (!parsed.util || !parsed.util.balances || !parsed.partners || !parsed.meta) {
      return createDefaultLedger();
    }
    return parsed;
  } catch (err) {
    console.error('Erreur lecture ledger DEMO, recréation :', err);
    return createDefaultLedger();
  }
}

export function saveLedger(ledger: OnchainDemoLedger): void {
  ledger.meta.updatedAt = new Date().toISOString();
  fs.writeFileSync(LEDGER_PATH, JSON.stringify(ledger, null, 2), 'utf-8');
}
EOF_LEDGER_TS
echo "[step11] src/onchain/ledger.ts écrit."

# 4) services/sync_chain.ts : logique DEMO de sync reward + register partner
cat <<'EOF_SYNC_TS' > services/sync_chain.ts
import fs from 'fs';
import path from 'path';
import { loadLedger, saveLedger } from '../src/onchain/ledger';

const USER_WALLET_PATH = path.join(process.cwd(), '..', 'USER_WALLET.json');

function getCreatorWallet(): string {
  try {
    const raw = fs.readFileSync(USER_WALLET_PATH, 'utf-8');
    const parsed = JSON.parse(raw);
    if (parsed.wallet_address && typeof parsed.wallet_address === 'string') {
      return parsed.wallet_address;
    }
  } catch (err) {
    console.error('Erreur lecture USER_WALLET.json :', err);
  }
  // Fallback: wallet nul en démo
  return '0x0000000000000000000000000000000000000000';
}

export interface SyncRewardInput {
  userId: string;
  partnerId: string;
  utilAmount: number;
}

/**
 * Simule UTIL.mint + royalties 2% pour le créateur.
 * - 98% pour l'utilisateur
 * - 2% pour le wallet créateur (USER_WALLET.json)
 */
export function syncRewardDemo(input: SyncRewardInput) {
  const creatorWallet = getCreatorWallet();
  const ledger = loadLedger();

  const total = Math.floor(input.utilAmount);
  if (total <= 0) {
    throw new Error('utilAmount doit être > 0');
  }

  const creatorAmount = Math.floor(total * 0.02);
  const userAmount = total - creatorAmount;

  const userKey = `user:${input.userId}`;
  const creatorKey = `wallet:${creatorWallet}`;

  const userBefore = ledger.util.balances[userKey] || 0;
  const creatorBefore = ledger.util.balances[creatorKey] || 0;

  ledger.util.balances[userKey] = userBefore + userAmount;
  ledger.util.balances[creatorKey] = creatorBefore + creatorAmount;

  if (!ledger.partners[input.partnerId]) {
    ledger.partners[input.partnerId] = {
      id: input.partnerId,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
  } else {
    ledger.partners[input.partnerId].updatedAt = new Date().toISOString();
  }

  saveLedger(ledger);

  return {
    input,
    split: {
      total,
      userAmount,
      creatorAmount,
    },
    balances: {
      user: {
        key: userKey,
        before: userBefore,
        after: ledger.util.balances[userKey],
      },
      creator: {
        key: creatorKey,
        before: creatorBefore,
        after: ledger.util.balances[creatorKey],
      },
    },
    ledgerMeta: ledger.meta,
  };
}

/**
 * Enregistre un partenaire accepté par l'AI dans le ledger DEMO,
 * en simulant PartnerRegistry.registerPartner.
 */
export function registerPartnerDemo(proposal: any, analysis: any) {
  const ledger = loadLedger();
  const partnerId: string =
    proposal.partnerId ||
    proposal.id ||
    (proposal.name ? String(proposal.name).toLowerCase().replace(/\s+/g, '_') : 'unknown_partner');

  const existing = ledger.partners[partnerId];
  const now = new Date().toISOString();

  ledger.partners[partnerId] = {
    ...(existing || {}),
    partnerId,
    name: proposal.name,
    sector: proposal.sector,
    country: proposal.country,
    rewardRate: proposal.rewardRate,
    activeUsers: proposal.activeUsers,
    decision: 'auto_accept',
    score: analysis?.score,
    risk: analysis?.risk,
    reasons: analysis?.reasons || [],
    status: 'active',
    createdAt: existing?.createdAt || now,
    updatedAt: now,
  };

  saveLedger(ledger);

  return {
    partnerId,
    stored: ledger.partners[partnerId],
  };
}
EOF_SYNC_TS
echo "[step11] services/sync_chain.ts écrit (logique DEMO pour sync reward + registre partenaire)."

# 5) Réécriture de ai.ts pour utiliser syncRewardDemo + registerPartnerDemo
cat <<'EOF_AI_TS' > ai.ts
import { Router, Request, Response } from 'express';
import {
  analyzeUsage,
  analyzePartner,
  evaluateOnboardPartner,
} from './fraud_detection';
import { syncRewardDemo, registerPartnerDemo } from './services/sync_chain';
import { encodeContext, decodeContext } from './services/qr_service';

const router = Router();

// Endpoint principal sur /api/ai
router.get('/', (_req: Request, res: Response) => {
  res.json({ status: 'AI endpoint OK', route: '/api/ai' });
});

// Endpoint santé AI
router.get('/status', (_req: Request, res: Response) => {
  res.json({ status: 'AI endpoint OK', route: '/api/ai/status' });
});

// Analyse d'un évènement d'usage
router.post('/analyze/usage', (req: Request, res: Response) => {
  const event = req.body;
  try {
    const analysis = analyzeUsage(event);
    return res.json({ event, analysis });
  } catch (err) {
    console.error('Erreur /analyze/usage:', err);
    return res.status(500).json({ error: 'Erreur interne analyse usage' });
  }
});

// Analyse d'un profil partenaire simple
router.post('/analyze/partner', (req: Request, res: Response) => {
  const profile = req.body;
  try {
    const analysis = analyzePartner(profile);
    return res.json({ profile, analysis });
  } catch (err) {
    console.error('Erreur /analyze/partner:', err);
    return res.status(500).json({ error: 'Erreur interne analyse partenaire' });
  }
});

// Onboarding partenaire coordonné par AI
router.post('/onboard/partner', (req: Request, res: Response) => {
  const proposal = req.body;
  try {
    const result: any = evaluateOnboardPartner(proposal);

    if (result.decision === 'auto_accept') {
      const onchainDemo = registerPartnerDemo(result.proposal, result.analysis);
      return res.json({
        ...result,
        onchainDemo,
      });
    }

    return res.json(result);
  } catch (err) {
    console.error('Erreur /onboard/partner:', err);
    return res.status(500).json({ error: 'Erreur interne onboarding partenaire' });
  }
});

// QR encode (contexte campagne/partenaire/utilisateur)
router.post('/qr/encode', (req: Request, res: Response) => {
  const context = req.body;
  try {
    const encoded = encodeContext(context);
    return res.json({ context, encoded });
  } catch (err) {
    console.error('Erreur /qr/encode:', err);
    return res.status(500).json({ error: 'Erreur interne QR encode' });
  }
});

// QR decode
router.post('/qr/decode', (req: Request, res: Response) => {
  const { encoded } = req.body;
  try {
    const decoded = decodeContext(encoded);
    return res.json({ encoded, decoded });
  } catch (err) {
    console.error('Erreur /qr/decode:', err);
    return res.status(500).json({ error: 'Erreur interne QR decode' });
  }
});

// Sync reward DEMO : applique 98% + 2% royalties créateur dans le ledger JSON
router.post('/sync/reward', (req: Request, res: Response) => {
  const { userId, partnerId, utilAmount } = req.body;
  if (
    typeof userId !== 'string' ||
    typeof partnerId !== 'string' ||
    typeof utilAmount !== 'number'
  ) {
    return res.status(400).json({
      error: 'Paramètres invalides',
      details: 'userId, partnerId doivent être des chaînes, utilAmount un nombre.',
    });
  }

  try {
    const result = syncRewardDemo({ userId, partnerId, utilAmount });
    return res.json(result);
  } catch (err) {
    console.error('Erreur /sync/reward:', err);
    return res.status(500).json({ error: 'Erreur interne sync reward DEMO' });
  }
});

export default router;
EOF_AI_TS
echo "[step11] ai.ts réécrit pour utiliser la couche onchain DEMO."

# 6) Compilation + redémarrage PM2
echo "[step11] Compilation TypeScript (npx tsc)..."
npx tsc

echo "[step11] (Re)lancement de l'API avec PM2..."
if pm2 describe "$PM2_NAME" >/dev/null 2>&1; then
  pm2 restart "$PM2_NAME" --update-env
else
  pm2 start dist/index.js --name "$PM2_NAME"
fi
pm2 save

echo "============================================================"
echo "[step11] Terminé. Tests recommandés :"
cat <<'EOF_TESTS'
cd /root/omniutil/backend
API_KEY=$(grep '^API_KEY' .env | cut -d= -f2-)

# 1) Sync reward DEMO
curl -k https://127.0.0.1:8443/api/ai/sync/reward \
  -H "x-api-key: $API_KEY" -H 'Content-Type: application/json' \
  -d '{"userId":"u1","partnerId":"p1","utilAmount":100}'

# 2) Voir le ledger DEMO onchain
cat onchain_demo_ledger.json

# 3) Onboard partenaire auto_accept (Airtel) et vérifier qu'il est enregistré dans partners
curl -k https://127.0.0.1:8443/api/ai/onboard/partner \
  -H "x-api-key: $API_KEY" -H 'Content-Type: application/json' \
  -d '{"name":"Airtel","sector":"mobile_network","activeUsers":5000000,"country":"CD","rewardRate":0.02,"currency":"CDF","usdRate":0.0004}'

cat onchain_demo_ledger.json | jq '.partners'
EOF_TESTS
echo "============================================================"
