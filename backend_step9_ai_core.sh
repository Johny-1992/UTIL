#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="/root/omniutil/backend"
PM2_NAME="omniutil-api"

echo "[step9] Configuration du bloc AI (fraud_detection + services + ai.ts)"
cd "$BACKEND_DIR"
echo "[step9] Dossier backend : $(pwd)"

# 1) Backups de sécurité
for f in ai.ts fraud_detection.ts services/event_listener.ts services/qr_service.ts services/sync_chain.ts; do
  if [ -f "$f" ] && [ ! -f "$f.step9.bak" ]; then
    cp "$f" "$f.step9.bak"
    echo "[step9] Backup créé : $f.step9.bak"
  fi
done

mkdir -p services

# 2) Réécriture de fraud_detection.ts (moteur de scoring TypeScript pur)
cat <<'EOF_FRAUD' > fraud_detection.ts
export type RiskLevel = 'low' | 'medium' | 'high';
export type RecommendedAction = 'allow' | 'review' | 'block';

export interface UsageEvent {
  userId: string;
  partnerId: string;
  amount: number;
  timestamp: string;
  country?: string;
  channel?: string;
  device?: string;
}

export interface PartnerProfile {
  partnerId: string;
  kycCompleted: boolean;
  country?: string;
  category?: string;
  complaints?: number;
}

export interface FraudAnalysisResult {
  score: number; // 0-100
  risk: RiskLevel;
  recommendedAction: RecommendedAction;
  reasons: string[];
}

function classify(score: number): { risk: RiskLevel; action: RecommendedAction } {
  if (score >= 80) return { risk: 'low', action: 'allow' };
  if (score >= 50) return { risk: 'medium', action: 'review' };
  return { risk: 'high', action: 'block' };
}

export function analyzeUsage(event: UsageEvent): FraudAnalysisResult {
  let score = 70;
  const reasons: string[] = [];

  if (event.amount <= 0) {
    score -= 40;
    reasons.push('amount_non_positive');
  }
  if (event.amount > 1000) {
    score -= 20;
    reasons.push('large_amount');
  }
  if (!event.country) {
    score -= 5;
    reasons.push('country_missing');
  }
  if (!event.channel) {
    score -= 5;
    reasons.push('channel_missing');
  }
  if (!event.device) {
    score -= 5;
    reasons.push('device_missing');
  }

  if (reasons.length === 0) {
    reasons.push('baseline_ok');
  }

  if (score < 0) score = 0;
  if (score > 100) score = 100;

  const { risk, action } = classify(score);
  return {
    score,
    risk,
    recommendedAction: action,
    reasons,
  };
}

export function analyzePartner(profile: PartnerProfile): FraudAnalysisResult {
  let score = 75;
  const reasons: string[] = [];

  if (!profile.kycCompleted) {
    score -= 30;
    reasons.push('kyc_incomplete');
  }
  if ((profile.complaints ?? 0) > 10) {
    score -= 20;
    reasons.push('many_complaints');
  }
  if (!profile.country) {
    score -= 5;
    reasons.push('country_missing');
  }
  if (!profile.category) {
    score -= 5;
    reasons.push('category_missing');
  }

  if (reasons.length === 0) {
    reasons.push('baseline_ok');
  }

  if (score < 0) score = 0;
  if (score > 100) score = 100;

  const { risk, action } = classify(score);
  return {
    score,
    risk,
    recommendedAction: action,
    reasons,
  };
}
EOF_FRAUD

echo "[step9] fraud_detection.ts réécrit."

# 3) services/event_listener.ts : enveloppe le moteur AI
cat <<'EOF_EVT' > services/event_listener.ts
import {
  analyzeUsage,
  analyzePartner,
  UsageEvent,
  PartnerProfile,
  FraudAnalysisResult,
} from '../fraud_detection';

export async function handleUsageEvent(event: UsageEvent): Promise<FraudAnalysisResult> {
  const analysis = analyzeUsage(event);
  console.log(JSON.stringify({ type: 'usage_event', event, analysis }));
  return analysis;
}

export async function handlePartnerProfile(profile: PartnerProfile): Promise<FraudAnalysisResult> {
  const analysis = analyzePartner(profile);
  console.log(JSON.stringify({ type: 'partner_profile', profile, analysis }));
  return analysis;
}
EOF_EVT

echo "[step9] services/event_listener.ts écrit."

# 4) services/qr_service.ts : encode/décode un contexte QR
cat <<'EOF_QR' > services/qr_service.ts
import { Request } from 'express';

export interface QrContext {
  partnerId: string;
  userId?: string;
  campaignId?: string;
  extra?: Record<string, unknown>;
}

export function encodeQrContext(ctx: QrContext): string {
  const json = JSON.stringify(ctx);
  return Buffer.from(json, 'utf8').toString('base64');
}

export function decodeQrContext(payload: string): QrContext {
  const json = Buffer.from(payload, 'base64').toString('utf8');
  const parsed = JSON.parse(json);
  if (!parsed.partnerId || typeof parsed.partnerId !== 'string') {
    throw new Error('Invalid QR context: missing partnerId');
  }
  return parsed as QrContext;
}

export function buildQrContextFromRequest(req: Request): QrContext {
  const { partnerId, userId, campaignId, ...rest } = req.body || {};
  if (typeof partnerId !== 'string') {
    throw new Error('partnerId is required to build QR context');
  }
  const ctx: QrContext = { partnerId };
  if (typeof userId === 'string') ctx.userId = userId;
  if (typeof campaignId === 'string') ctx.campaignId = campaignId;
  if (Object.keys(rest).length > 0) ctx.extra = rest as Record<string, unknown>;
  return ctx;
}
EOF_QR

echo "[step9] services/qr_service.ts écrit."

# 5) services/sync_chain.ts : stub de synchronisation on-chain
cat <<'EOF_SYNC' > services/sync_chain.ts
export interface OnChainReward {
  userId: string;
  partnerId: string;
  utilAmount: number;
  txMetadata?: Record<string, unknown>;
}

export interface OnChainResult {
  success: boolean;
  txHash: string;
  network: string;
}

export async function recordRewardOnChain(payload: OnChainReward): Promise<OnChainResult> {
  const network = process.env.CHAIN_NETWORK || 'demo';
  const txHash = `demo-${Date.now()}-${Math.random().toString(16).slice(2, 10)}`;
  console.log(JSON.stringify({ type: 'onchain_reward', network, payload, txHash }));
  return {
    success: true,
    txHash,
    network,
  };
}
EOF_SYNC

echo "[step9] services/sync_chain.ts écrit."

# 6) Réécriture de ai.ts pour utiliser ces services
cat <<'EOF_AI' > ai.ts
import { Router, Request, Response } from 'express';
import { handleUsageEvent, handlePartnerProfile } from './services/event_listener';
import { buildQrContextFromRequest, encodeQrContext, decodeQrContext } from './services/qr_service';
import { recordRewardOnChain } from './services/sync_chain';
import { UsageEvent, PartnerProfile } from './fraud_detection';

const router = Router();

// Endpoint principal sur /api/ai
router.get('/', (_req: Request, res: Response) => {
  res.json({ status: 'AI endpoint OK', route: '/api/ai' });
});

// Endpoint supplémentaire sur /api/ai/status
router.get('/status', (_req: Request, res: Response) => {
  res.json({ status: 'AI endpoint OK', route: '/api/ai/status' });
});

// POST /api/ai/analyze/usage
router.post('/analyze/usage', async (req: Request, res: Response) => {
  const { userId, partnerId, amount, country, channel, device, timestamp } = req.body || {};
  if (typeof userId !== 'string' || typeof partnerId !== 'string' || typeof amount !== 'number') {
    return res.status(400).json({
      error: 'Paramètres invalides',
      details: 'userId, partnerId (string) et amount (number) sont requis.',
    });
  }

  const event: UsageEvent = {
    userId,
    partnerId,
    amount,
    timestamp: typeof timestamp === 'string' ? timestamp : new Date().toISOString(),
    country: typeof country === 'string' ? country : undefined,
    channel: typeof channel === 'string' ? channel : undefined,
    device: typeof device === 'string' ? device : undefined,
  };

  try {
    const analysis = await handleUsageEvent(event);
    return res.json({ event, analysis });
  } catch (err) {
    console.error('Erreur dans /api/ai/analyze/usage :', err);
    return res.status(500).json({ error: 'Erreur interne lors de l’analyse d’usage' });
  }
});

// POST /api/ai/analyze/partner
router.post('/analyze/partner', async (req: Request, res: Response) => {
  const { partnerId, kycCompleted, country, category, complaints } = req.body || {};
  if (typeof partnerId !== 'string' || typeof kycCompleted !== 'boolean') {
    return res.status(400).json({
      error: 'Paramètres invalides',
      details: 'partnerId (string) et kycCompleted (boolean) sont requis.',
    });
  }

  const profile: PartnerProfile = {
    partnerId,
    kycCompleted,
    country: typeof country === 'string' ? country : undefined,
    category: typeof category === 'string' ? category : undefined,
    complaints: typeof complaints === 'number' ? complaints : undefined,
  };

  try {
    const analysis = await handlePartnerProfile(profile);
    return res.json({ profile, analysis });
  } catch (err) {
    console.error('Erreur dans /api/ai/analyze/partner :', err);
    return res.status(500).json({ error: 'Erreur interne lors de l’analyse partenaire' });
  }
});

// POST /api/ai/qr/encode
router.post('/qr/encode', (req: Request, res: Response) => {
  try {
    const ctx = buildQrContextFromRequest(req);
    const payload = encodeQrContext(ctx);
    return res.json({ payload, context: ctx });
  } catch (err: any) {
    console.error('Erreur dans /api/ai/qr/encode :', err);
    return res.status(400).json({ error: 'Erreur lors de la création du QR', details: err.message || String(err) });
  }
});

// POST /api/ai/qr/decode
router.post('/qr/decode', (req: Request, res: Response) => {
  const { payload } = req.body || {};
  if (typeof payload !== 'string') {
    return res.status(400).json({ error: 'Paramètres invalides', details: 'payload (string) requis.' });
  }
  try {
    const context = decodeQrContext(payload);
    return res.json({ context });
  } catch (err: any) {
    console.error('Erreur dans /api/ai/qr/decode :', err);
    return res.status(400).json({ error: 'QR invalide', details: err.message || String(err) });
  }
});

// POST /api/ai/sync/reward
router.post('/sync/reward', async (req: Request, res: Response) => {
  const { userId, partnerId, utilAmount, ...txMetadata } = req.body || {};
  if (typeof userId !== 'string' || typeof partnerId !== 'string' || typeof utilAmount !== 'number') {
    return res.status(400).json({
      error: 'Paramètres invalides',
      details: 'userId, partnerId (string) et utilAmount (number) sont requis.',
    });
  }
  try {
    const result = await recordRewardOnChain({
      userId,
      partnerId,
      utilAmount,
      txMetadata,
    });
    return res.json(result);
  } catch (err) {
    console.error('Erreur dans /api/ai/sync/reward :', err);
    return res.status(500).json({ error: 'Erreur interne lors de la synchronisation on-chain' });
  }
});

export default router;
EOF_AI

echo "[step9] ai.ts réécrit avec endpoints AI avancés."

# 7) Compilation + PM2
echo "[step9] Compilation TypeScript (npx tsc)..."
npx tsc

echo "[step9] (Re)lancement de l'API avec PM2..."
if pm2 describe "$PM2_NAME" >/dev/null 2>&1; then
  pm2 restart "$PM2_NAME" --update-env
else
  pm2 start dist/index.js --name "$PM2_NAME"
fi

pm2 save

echo "============================================================"
echo "[step9] Terminé. Tests recommandés :"
echo "  cd /root/omniutil/backend"
echo "  API_KEY=\$(grep '^API_KEY' .env | cut -d= -f2-)"
echo
echo "  # 1) Analyse usage :"
echo "  curl -k https://127.0.0.1:8443/api/ai/analyze/usage \\"
echo "    -H \"x-api-key: \$API_KEY\" -H 'Content-Type: application/json' \\"
echo "    -d '{\"userId\":\"u1\",\"partnerId\":\"p1\",\"amount\":120,\"country\":\"FR\",\"channel\":\"web\",\"device\":\"mobile\"}'"
echo
echo "  # 2) Analyse partenaire :"
echo "  curl -k https://127.0.0.1:8443/api/ai/analyze/partner \\"
echo "    -H \"x-api-key: \$API_KEY\" -H 'Content-Type: application/json' \\"
echo "    -d '{\"partnerId\":\"p1\",\"kycCompleted\":true,\"country\":\"FR\",\"category\":\"telco\",\"complaints\":0}'"
echo
echo "  # 3) QR encode/decode :"
echo "  curl -k https://127.0.0.1:8443/api/ai/qr/encode \\"
echo "    -H \"x-api-key: \$API_KEY\" -H 'Content-Type: application/json' \\"
echo "    -d '{\"partnerId\":\"p1\",\"userId\":\"u1\",\"campaignId\":\"c1\"}'"
echo
echo "  # 4) Sync reward on-chain (stub) :"
echo "  curl -k https://127.0.0.1:8443/api/ai/sync/reward \\"
echo "    -H \"x-api-key: \$API_KEY\" -H 'Content-Type: application/json' \\"
echo "    -d '{\"userId\":\"u1\",\"partnerId\":\"p1\",\"utilAmount\":42}'"
echo "============================================================"
