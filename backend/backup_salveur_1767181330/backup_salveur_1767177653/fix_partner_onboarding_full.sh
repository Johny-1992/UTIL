#!/bin/bash
# fix_partner_onboarding_full.sh
# Script salvateur et correcteur OmniUtil Partner Onboarding

echo "🚀 Début du fix complet Partner Onboarding OmniUtil..."

# 1️⃣ Créer src/models/partnerRequest.ts si manquant
MODEL_FILE="src/models/partnerRequest.ts"
if [ ! -f "$MODEL_FILE" ]; then
  echo "💾 partnerRequest.ts manquant → création automatique..."
  mkdir -p src/models
  cat > $MODEL_FILE <<EOL
import { BaseModel } from './baseModel';

export type PartnerRequestStatus = 'PENDING_AI' | 'AUTO_ACCEPTED' | 'AUTO_REJECTED' | 'WAITING_SIGNER' | 'APPROVED';

export interface PartnerRequest extends BaseModel {
  uuid: string;
  name: string;
  activeUsers: number;
  reputationScore: number;
  status: PartnerRequestStatus;
  requestedAt: Date;
}

export const PartnerRequestSchema = {
  uuid: String,
  name: String,
  activeUsers: Number,
  reputationScore: Number,
  status: String,
  requestedAt: Date,
};
EOL
  echo "✅ partnerRequest.ts créé"
else
  echo "ℹ️ partnerRequest.ts déjà présent"
fi

# 2️⃣ Harmoniser imports AuditEvent
AUDIT_FILE="src/utils/auditLogger.ts"
if [ -f "$AUDIT_FILE" ]; then
  echo "🔧 Harmonisation AuditEvent dans partnerRequestProcessor.ts..."
  sed -i.bak 's|import { AuditEvent } from "../utils/audit"|import { AuditEvent } from "../utils/auditLogger"|g' src/services/partnerRequestProcessor.ts
  echo "✅ AuditEvent harmonisé et import corrigé"
else
  echo "⚠️ auditLogger.ts manquant ! Veuillez créer le fichier avant de continuer"
fi

# 3️⃣ Corriger usage Audit dans partnerRequestProcessor.ts
echo "🔄 Typage ONBOARD_REQUEST en 'as AuditEvent'..."
sed -i.bak 's|audit("ONBOARD_REQUEST".*|audit("ONBOARD_REQUEST" as AuditEvent, { uuid, decision, timestamp: new Date() });|g' src/services/partnerRequestProcessor.ts
echo "✅ Audit ONBOARD_REQUEST typé correctement"

# 4️⃣ Vérifier existence partnerRequestProcessor.ts
PROCESSOR_FILE="src/services/partnerRequestProcessor.ts"
if [ ! -f "$PROCESSOR_FILE" ]; then
  echo "⚠️ partnerRequestProcessor.ts manquant !"
else
  echo "ℹ️ partnerRequestProcessor.ts présent"
fi

# 5️⃣ Backup et compilation TS pour valider tout
echo "💾 Création backup du projet..."
tar czf backup_omnutil_$(date +%Y%m%d_%H%M%S).tar.gz src/

echo "🧪 Compilation TypeScript..."
npx tsc --noEmit
if [ $? -eq 0 ]; then
  echo "🎉 Compilation TypeScript réussie — Partner Onboarding prêt"
else
  echo "⚠️ Erreurs TypeScript détectées — vérifier manuellement"
fi

echo "🚀 Fix complet Partner Onboarding terminé !"
