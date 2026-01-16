interface EcosystemInfo {
  name: string;
  subscribers: number;
  trustScore: number; // Score de confiance basé sur plusieurs critères
}

export async function evaluatePartnershipRequest(ecosystemId: string): Promise<{ status: string; message: string; ecosystemId: string }> {
  const ecosystemInfo = await getEcosystemInfo(ecosystemId);
  const score = calculateTrustScore(ecosystemInfo);

  if (score >= 80) {
    return {
      status: "approved",
      message: `Partenariat avec ${ecosystemInfo.name} approuvé automatiquement. Score: ${score}/100.`,
      ecosystemId: ecosystemId
    };
  } else if (score >= 50) {
    return {
      status: "pending",
      message: `Partenariat avec ${ecosystemInfo.name} en attente de validation. Score: ${score}/100.`,
      ecosystemId: ecosystemId
    };
  } else {
    return {
      status: "rejected",
      message: `Partenariat avec ${ecosystemInfo.name} rejeté automatiquement. Score: ${score}/100.`,
      ecosystemId: ecosystemId
    };
  }
}

function calculateTrustScore(ecosystemInfo: EcosystemInfo): number {
  // Logique de calcul du score (exemple simplifié)
  let score = 0;

  // Nombre d'abonnés
  if (ecosystemInfo.subscribers >= 5000000) {
    score += 40;
  } else if (ecosystemInfo.subscribers >= 1000000) {
    score += 30;
  } else {
    score += 10;
  }

  // Score de confiance supplémentaire
  score += ecosystemInfo.trustScore;

  return Math.min(score, 100); // Le score maximum est 100
}

async function getEcosystemInfo(ecosystemId: string): Promise<EcosystemInfo> {
  // Simuler la récupération des informations de l'écosystème
  const ecosystems: Record<string, EcosystemInfo> = {
    "airtel": { name: "Airtel", subscribers: 5000000, trustScore: 45 },
    "ecosystem2": { name: "Ecosystem2", subscribers: 1000000, trustScore: 30 },
    "ecosystem3": { name: "Ecosystem3", subscribers: 500000, trustScore: 10 }
  };

  return ecosystems[ecosystemId] || { name: "Unknown", subscribers: 0, trustScore: 0 };
}
