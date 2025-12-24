#!/usr/bin/env bash
set -euo pipefail

BACKEND_DIR="/root/omniutil/backend"
PM2_NAME="omniutil-api"

echo "[step10] Configuration AI d'onboarding partenaire (fraud_detection + ai.ts)"
cd "$BACKEND_DIR"
echo "[step10] Dossier backend : $(pwd)"

# 1) Backups de sécurité
for f in ai.ts fraud_detection.ts; do
  if [ -f "$f" ] && [ ! -f "$f.step10.bak" ]; then
    cp "$f" "$f.step10.bak"
    echo "[step10] Backup créé : $f.step10.bak"
  fi
done

########################################
# 2) Réécriture complète de fraud_detection.ts
########################################

cat <<'EOF_FRAUD' > fraud_detection.ts
export type RiskLevel = 'low' | 'medium' | 'high';
export type RecommendedAction = 'allow' | 'review' | 'block';

export interface FraudAnalysisResult {
  score: number;              // 0-100
  risk: RiskLevel;
  recommendedAction: RecommendedAction;
  reasons: string[];
}

// --- Classification générique ---

function classify(score: number): { risk: RiskLevel; recommendedAction: RecommendedAction } {
  if (score >= 80) {
    return { risk: 'low', recommendedAction: 'allow' };
  }
  if (score >= 50) {
    return { risk: 'medium', recommendedAction: 'review' };
  }
  return { risk: 'high', recommendedAction: 'block' };
}

// --- Analyse d'un évènement d'usage ---

export interface UsageEvent {
  userId: string;
  partnerId: string;
  amount: number;
  timestamp: string;
  country?: string;
  channel?: string;
  device?: string;
}

export function analyzeUsage(event: UsageEvent): FraudAnalysisResult {
  let score = 70;
  const reasons: string[] = [];

  if (event.amount <= 0) {
    score -= 40;
    reasons.push('amount_non_positive');
  } else if (event.amount > 1000) {
    score -= 20;
    reasons.push('large_amount');
  } else {
    reasons.push('baseline_ok');
  }

  if (!event.country) {
    score -= 5;
    reasons.push('no_country');
  }

  const { risk, recommendedAction } = classify(score);
  return { score, risk, recommendedAction, reasons };
}

// --- Analyse d'un profil partenaire simple ---

export interface PartnerProfile {
  partnerId: string;
  kycCompleted: boolean;
  country?: string;
  category?: string;
  complaints?: number;
}

export function analyzePartner(profile: PartnerProfile): FraudAnalysisResult {
  let score = 70;
  const reasons: string[] = [];

  if (profile.kycCompleted) {
    score += 10;
    reasons.push('kyc_completed');
  } else {
    score -= 20;
    reasons.push('no_kyc');
  }

  if (typeof profile.complaints === 'number') {
    if (profile.complaints === 0) {
      score += 5;
      reasons.push('no_complaints');
    } else if (profile.complaints > 10) {
      score -= 20;
      reasons.push('many_complaints');
    }
  }

  if (profile.country === 'FR' || profile.country === 'BE' || profile.country === 'CH' ||
      profile.country === 'DE' || profile.country === 'US' || profile.country === 'CA') {
    score += 5;
    reasons.push('trusted_country');
  }

  const { risk, recommendedAction } = classify(score);
  return { score, risk, recommendedAction, reasons };
}

// --- Proposition d'onboarding partenaire (via QR) ---

export interface PartnerOnboardingProposal {
  name: string;         // ex: "Airtel"
  sector: string;       // ex: "mobile_network", "tv_subscription", "casino", "e_bank"
  activeUsers: number;  // ex: 5000000
  country: string;      // code pays
  rewardRate: number;   // ex: 0.02 pour 2% de récompense
  currency: string;     // ex: "CDF", "EUR", ...
  usdRate: number;      // taux de change vers USD (1 unité de currency en USD)
}

export type PartnerOnboardingDecisionType =
  | 'auto_accept'
  | 'needs_human_review'
  | 'auto_reject';

export interface PartnerOnboardingDecision {
  proposal: PartnerOnboardingProposal;
  analysis: FraudAnalysisResult;
  decision: PartnerOnboardingDecisionType;
  message: string;
}

// --- Heuristiques d'onboarding partenaire ---

export function evaluatePartnerOnboarding(
  proposal: PartnerOnboardingProposal
): PartnerOnboardingDecision {
  let score = 70;
  const reasons: string[] = [];

  // 1) Taille de la base utilisateurs
  if (proposal.activeUsers >= 5_000_000) {
    score += 15;
    reasons.push('many_active_users');
  } else if (proposal.activeUsers >= 1_000_000) {
    score += 10;
    reasons.push('large_user_base');
  } else if (proposal.activeUsers >= 100_000) {
    score += 5;
    reasons.push('medium_user_base');
  } else if (proposal.activeUsers < 10_000) {
    score -= 10;
    reasons.push('very_small_user_base');
  }

  // 2) Secteur d'activité
  const trustedSectors = ['mobile_network', 'telco', 'tv_subscription', 'supermarket', 'ecommerce', 'e_bank', 'bank'];
  const sensitiveSectors = ['casino', 'online_betting', 'gambling'];

  if (trustedSectors.includes(proposal.sector)) {
    score += 10;
    reasons.push('trusted_sector');
  } else if (sensitiveSectors.includes(proposal.sector)) {
    score -= 15;
    reasons.push('sensitive_sector');
  } else {
    reasons.push('neutral_sector');
  }

  // 3) RewardRate (taux de récompense)
  if (proposal.rewardRate <= 0) {
    score -= 30;
    reasons.push('invalid_reward_rate');
  } else if (proposal.rewardRate <= 0.05) {
    score += 5;
    reasons.push('reasonable_reward_rate');
  } else if (proposal.rewardRate > 0.15) {
    score -= 15;
    reasons.push('very_high_reward_rate');
  } else {
    reasons.push('high_reward_rate');
  }

  // 4) Taux de change USD
  if (proposal.usdRate <= 0 || proposal.usdRate > 1000) {
    score -= 20;
    reasons.push('invalid_fx_rate');
  } else {
    reasons.push('fx_rate_ok');
  }

  // 5) Pays (exemple simple, à affiner)
  const trustedCountries = ['FR', 'BE', 'CH', 'DE', 'US', 'CA', 'GB'];
  if (trustedCountries.includes(proposal.country)) {
    score += 5;
    reasons.push('trusted_country');
  }

  const { risk, recommendedAction } = classify(score);

  let decision: PartnerOnboardingDecisionType;
  let message: string;

  if (risk === 'low' && recommendedAction === 'allow') {
    decision = 'auto_accept';
    message = 'Partenaire automatiquement accepté par l’AI coordonnateur.';
  } else if (risk === 'high') {
    decision = 'auto_reject';
    message = 'Profil partenaire jugé trop risqué. Rejet automatique.';
  } else {
    decision = 'needs_human_review';
    message = 'Partenaire mis en attente pour examen humain (admin signataire).';
  }

  const analysis: FraudAnalysisResult = { score, risk, recommendedAction, reasons };
  return { proposal, analysis, decision, message };
}
EOF_FRAUD

echo "[step10] fraud_detection.ts réécrit avec evaluation d'onboarding partenaire."

########################################
# 3) Réécriture de ai.ts avec endpoint /onboard/partner
########################################

cat <<'EOF_AI' > ai.ts
import { Router, Request, Response } from 'express';
import {
  analyzeUsage,
  analyzePartner,
  evaluatePartnerOnboarding,
  PartnerOnboardingProposal,
} from './fraud_detection';

const router = Router();

// GET /api/ai
router.get('/', (_req: Request, res: Response) => {
  res.json({ status: 'AI endpoint OK', route: '/api/ai' });
});

// GET /api/ai/status
router.get('/status', (_req: Request, res: Response) => {
  res.json({ status: 'AI endpoint OK', route: '/api/ai/status' });
});

// POST /api/ai/analyze/usage
router.post('/analyze/usage', (req: Request, res: Response) => {
  const event = req.body;
  if (!event.userId || !event.partnerId || typeof event.amount !== 'number') {
    return res.status(400).json({
      error: 'Paramètres invalides pour analyse usage',
      details: 'userId, partnerId et amount sont requis',
    });
  }
  // Ajouter un timestamp si absent
  if (!event.timestamp) {
    event.timestamp = new Date().toISOString();
  }
  const analysis = analyzeUsage(event);
  return res.json({ event, analysis });
});

// POST /api/ai/analyze/partner
router.post('/analyze/partner', (req: Request, res: Response) => {
  const profile = req.body;
  if (!profile.partnerId) {
    return res.status(400).json({
      error: 'Paramètres invalides pour analyse partenaire',
      details: 'partnerId est requis',
    });
  }
  const analysis = analyzePartner(profile);
  return res.json({ profile, analysis });
});

// POST /api/ai/onboard/partner
router.post('/onboard/partner', (req: Request, res: Response) => {
  const proposal = req.body as PartnerOnboardingProposal;

  if (
    !proposal.name ||
    !proposal.sector ||
    typeof proposal.activeUsers !== 'number' ||
    !proposal.country ||
    typeof proposal.rewardRate !== 'number' ||
    !proposal.currency ||
    typeof proposal.usdRate !== 'number'
  ) {
    return res.status(400).json({
      error: 'Paramètres invalides pour onboarding partenaire',
      details:
        'name, sector, activeUsers, country, rewardRate, currency et usdRate sont requis',
    });
  }

  try {
    const decision = evaluatePartnerOnboarding(proposal);
    return res.json(decision);
  } catch (err) {
    console.error('Erreur dans evaluatePartnerOnboarding:', err);
    return res.status(500).json({
      error: 'Erreur interne lors de l’évaluation AI d’onboarding partenaire',
    });
  }
});

export default router;
EOF_AI

echo "[step10] ai.ts réécrit avec endpoint /api/ai/onboard/partner."

########################################
# 4) Compilation + redémarrage PM2
########################################

echo "[step10] Compilation TypeScript (npx tsc)..."
npx tsc

echo "[step10] (Re)lancement de l'API avec PM2..."
if pm2 describe "$PM2_NAME" >/dev/null 2>&1; then
  pm2 restart "$PM2_NAME" --update-env
else
  pm2 start dist/index.js --name "$PM2_NAME"
fi
pm2 save

echo "============================================================"
echo "[step10] Terminé. Tests recommandés :"
echo "cd /root/omniutil/backend"
echo "API_KEY=\$(grep '^API_KEY' .env | cut -d= -f2-)"
echo
echo "# Partenaire sérieux (ex: Airtel)"
echo "curl -k https://127.0.0.1:8443/api/ai/onboard/partner \\"
echo "  -H \"x-api-key: \$API_KEY\" -H 'Content-Type: application/json' \\"
echo "  -d '{\"name\":\"Airtel\",\"sector\":\"mobile_network\",\"activeUsers\":5000000,\"country\":\"CD\",\"rewardRate\":0.02,\"currency\":\"CDF\",\"usdRate\":0.0004}'"
echo
echo "# Partenaire borderline (needs_human_review)"
echo "curl -k https://127.0.0.1:8443/api/ai/onboard/partner \\"
echo "  -H \"x-api-key: \$API_KEY\" -H 'Content-Type: application/json' \\"
echo "  -d '{\"name\":\"SmallBet\",\"sector\":\"online_betting\",\"activeUsers\":20000,\"country\":\"XX\",\"rewardRate\":0.1,\"currency\":\"XYZ\",\"usdRate\":0.001}'"
echo
echo "# Partenaire non crédible (auto_reject)"
echo "curl -k https://127.0.0.1:8443/api/ai/onboard/partner \\"
echo "  -H \"x-api-key: \$API_KEY\" -H 'Content-Type: application/json' \\"
echo "  -d '{\"name\":\"ScamCasino\",\"sector\":\"casino\",\"activeUsers\":1000,\"country\":\"ZZ\",\"rewardRate\":0.3,\"currency\":\"SCM\",\"usdRate\":-1}'"
echo "============================================================"
