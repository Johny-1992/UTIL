#!/bin/bash
# fix_partner_onboarding_ultimate.sh
# 🛠️ Fix complet Partner Onboarding OmniUtil – ultime

echo "🚀 Début du fix ultime Partner Onboarding OmniUtil..."

# Dossier des modèles
MODEL_DIR="src/models"
SERVICE_DIR="src/services"
UTIL_DIR="src/utils"

# Backup global
echo "💾 Création d'une sauvegarde temporaire du projet..."
BACKUP_DIR="backup_onboarding_$(date +%s)"
mkdir -p "$BACKUP_DIR"
cp -r src "$BACKUP_DIR/"

# 1️⃣ Création automatique baseModel.ts si manquant
if [ ! -f "$MODEL_DIR/baseModel.ts" ]; then
    echo "💾 baseModel.ts manquant → création automatique..."
    cat > "$MODEL_DIR/baseModel.ts" <<EOL
export interface BaseModel {
  id?: string;
  createdAt?: Date;
  updatedAt?: Date;
}
EOL
    echo "✅ baseModel.ts créé"
fi

# 2️⃣ Création PartnerRequest.ts si manquant
if [ ! -f "$MODEL_DIR/partnerRequest.ts" ]; then
    echo "💾 partnerRequest.ts manquant → création automatique..."
    cat > "$MODEL_DIR/partnerRequest.ts" <<EOL
import { BaseModel } from './baseModel';

export interface PartnerRequest extends BaseModel {
  uuid: string;
  name: string;
  activeUsers: number;
  reputationScore?: number;
  status: 'PENDING_AI' | 'AUTO_ACCEPTED' | 'AUTO_REJECTED' | 'WAITING_SIGNER' | 'APPROVED';
}
EOL
    echo "✅ partnerRequest.ts créé"
fi

# 3️⃣ Harmonisation imports AuditEvent dans partnerRequestProcessor.ts
PROCESSOR="$SERVICE_DIR/partnerRequestProcessor.ts"
if [ -f "$PROCESSOR" ]; then
    echo "🔧 Harmonisation import AuditEvent dans partnerRequestProcessor.ts..."
    # Remplacer tout import AuditEvent existant
    sed -i '/import.*AuditEvent/d' "$PROCESSOR"
    sed -i "1i import { audit, AuditEvent } from '../utils/auditLogger';" "$PROCESSOR"
    # Forcer typage ONBOARD_REQUEST
    sed -i "s/audit(\"ONBOARD_REQUEST\".*)/audit(\"ONBOARD_REQUEST\" as AuditEvent, { uuid, decision, timestamp: new Date() });/" "$PROCESSOR"
    echo "✅ AuditEvent harmonisé et typage ONBOARD_REQUEST corrigé"
fi

# 4️⃣ Compilation TypeScript
echo "🧪 Compilation TypeScript..."
tsc --noEmit
if [ $? -eq 0 ]; then
    echo "🎉 Compilation réussie — Partner Onboarding OmniUtil prêt !"
else
    echo "⚠️ Des erreurs TypeScript persistent, vérifier manuellement."
fi
