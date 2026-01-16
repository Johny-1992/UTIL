#!/bin/bash
echo "🚀 Initialisation Partner Onboarding OmniUtil..."

# Vérification dossier models
mkdir -p src/models
echo "📂 src/models OK"

# Création PartnerRequest Model si absent
PARTNER_MODEL="src/models/partnerRequestModel.ts"
if [ ! -f "$PARTNER_MODEL" ]; then
cat <<EOL > $PARTNER_MODEL
export interface PartnerRequest {
  id: string;
  name: string;
  country: string;
  type: 'telco' | 'ecommerce' | 'streaming' | 'other';
  activeUsers: number;
  rewardRate: number; // % en UTIL
  wallet: string;
  status: 'PENDING_AI' | 'AUTO_ACCEPTED' | 'AUTO_REJECTED' | 'WAITING_SIGNER' | 'APPROVED';
  createdAt: Date;
  updatedAt: Date;
}

export const partnerRequests: Record<string, PartnerRequest> = {};
EOL
  echo "✅ PartnerRequest Model créé"
else
  echo "ℹ️ PartnerRequest Model existe déjà"
fi

# Vérification dossier services
mkdir -p src/services
echo "📂 src/services OK"

# Création PartnerService si absent
PARTNER_SERVICE="src/services/partnerOnboardingService.ts"
if [ ! -f "$PARTNER_SERVICE" ]; then
cat <<EOL > $PARTNER_SERVICE
import { PartnerRequest, partnerRequests } from "../models/partnerRequestModel";

export const createPartnerRequest = (request: Omit<PartnerRequest, 'id'|'status'|'createdAt'|'updatedAt'>) => {
  const id = 'p_' + Date.now();
  partnerRequests[id] = {
    ...request,
    id,
    status: 'PENDING_AI',
    createdAt: new Date(),
    updatedAt: new Date(),
  };
  return partnerRequests[id];
};

export const updatePartnerStatus = (id: string, status: PartnerRequest['status']) => {
  if (partnerRequests[id]) {
    partnerRequests[id].status = status;
    partnerRequests[id].updatedAt = new Date();
    return partnerRequests[id];
  }
  return null;
};

export const listPartnerRequests = () => Object.values(partnerRequests);
EOL
  echo "✅ PartnerOnboardingService créé"
else
  echo "ℹ️ PartnerOnboardingService existe déjà"
fi

# Vérification TypeScript
npx tsc --noEmit
echo "🧪 Vérification TypeScript terminée"
echo "🎉 INIT PARTNER ONBOARDING COMPLET"
