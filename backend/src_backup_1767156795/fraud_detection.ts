export type RiskLevel = 'low' | 'medium' | 'high';
export type RecommendedAction = 'allow' | 'review' | 'block';
export type PartnerOnboardDecision = 'auto_accept' | 'needs_human_review' | 'auto_reject';

export interface FraudAnalysisResult {
  score: number; // 0-100
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

// =========================
// 1) Analyse d'un évènement d'usage
// =========================

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

// =========================
// 2) Analyse d'un profil partenaire simple
// =========================

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

  if (
    profile.country === 'FR' ||
    profile.country === 'BE' ||
    profile.country === 'CH' ||
    profile.country === 'DE' ||
    profile.country === 'US' ||
    profile.country === 'CA'
  ) {
    score += 5;
    reasons.push('trusted_country');
  }

  const { risk, recommendedAction } = classify(score);
  return { score, risk, recommendedAction, reasons };
}

// =========================
// 3) Evaluation d'onboarding partenaire (Airtel / SmallBet / ScamCasino)
// =========================

export interface PartnerOnboardProposal {
  name: string;
  sector: string;
  activeUsers: number;
  country?: string;
  rewardRate: number;
  currency?: string;
  usdRate: number;
}

export interface PartnerOnboardResult {
  proposal: PartnerOnboardProposal;
  analysis: FraudAnalysisResult;
  decision: PartnerOnboardDecision;
  message: string;
}

export function evaluateOnboardPartner(proposal: PartnerOnboardProposal): PartnerOnboardResult {
  let score = 70;
  const reasons: string[] = [];

  const { sector, activeUsers, rewardRate, usdRate } = proposal;

  // Taille base utilisateurs
  if (activeUsers >= 1_000_000) {
    score += 20;
    reasons.push('many_active_users');
  } else if (activeUsers >= 100_000) {
    score += 5;
    reasons.push('medium_user_base');
  } else if (activeUsers < 10_000) {
    score -= 15;
    reasons.push('very_small_user_base');
  }

  // Secteur
  const trustedSectors = [
    'mobile_network',
    'bank',
    'e_bank',
    'ecommerce',
    'supermarket',
    'tv_subscription',
    'streaming',
  ];
  const sensitiveSectors = ['online_betting', 'casino', 'gambling'];

  if (trustedSectors.includes(sector)) {
    score += 10;
    reasons.push('trusted_sector');
  }

  if (sensitiveSectors.includes(sector)) {
    score -= 10;
    reasons.push('sensitive_sector');
  }

  // Taux de reward
  if (!Number.isFinite(rewardRate) || rewardRate <= 0) {
    score -= 25;
    reasons.push('invalid_reward_rate');
  } else if (rewardRate <= 0.05) {
    score += 5;
    reasons.push('reasonable_reward_rate');
  } else if (rewardRate <= 0.15) {
    score -= 5;
    reasons.push('high_reward_rate');
  } else {
    score -= 15;
    reasons.push('very_high_reward_rate');
  }

  // Taux FX
  if (!Number.isFinite(usdRate) || usdRate <= 0) {
    score -= 20;
    reasons.push('invalid_fx_rate');
  } else {
    reasons.push('fx_rate_ok');
  }

  if (score < 0) score = 0;
  if (score > 100) score = 100;

  const { risk, recommendedAction } = classify(score);
  let decision: PartnerOnboardDecision;
  let message: string;

  if (recommendedAction === 'allow') {
    decision = 'auto_accept';
    message = "Partenaire automatiquement accepté par l’AI coordonnateur.";
  } else if (recommendedAction === 'review') {
    decision = 'needs_human_review';
    message = "Partenaire mis en attente pour examen humain (admin signataire).";
  } else {
    decision = 'auto_reject';
    message = "Profil partenaire jugé trop risqué. Rejet automatique.";
  }

  const analysis: FraudAnalysisResult = { score, risk, recommendedAction, reasons };
  return { proposal, analysis, decision, message };
}
