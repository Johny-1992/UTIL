#!/bin/bash
echo "🚀 Début du fix final Partner Onboarding OmniUtil..."

# Backup complet du dossier backend
echo "💾 Création d'une sauvegarde complète du projet..."
cp -r ./src ./src_backup_$(date +%s)

# 1️⃣ Nettoyage des imports doublons dans partnerRequestProcessor.ts
echo "🧹 Nettoyage des imports doublons..."
sed -i '/import { audit/d' ./src/services/partnerRequestProcessor.ts
echo "import { audit, AuditEvent } from '../utils/auditLogger';" | cat - ./src/services/partnerRequestProcessor.ts > temp && mv temp ./src/services/partnerRequestProcessor.ts

# 2️⃣ Harmonisation type AuditEvent
echo "🛠️ Harmonisation type AuditEvent..."
AUDIT_FILE="./src/utils/auditLogger.ts"
if [ ! -f "$AUDIT_FILE" ]; then
    echo "📄 auditLogger.ts manquant → création..."
    cat <<EOL > $AUDIT_FILE
export type AuditEvent =
  | "ONBOARD_REQUEST"
  | "EXCHANGE_USDT"
  | "TRANSFER_UTIL"
  | "PARTNER_ONBOARD_DECISION"
  | "FRAUD_BLOCK";

export function audit(event: AuditEvent, data: any) {
    console.log(\`[AUDIT] \${event} ->\`, data);
}
EOL
fi

# 3️⃣ Supprimer tous les anciens backups conflictuels
echo "🗑️ Suppression backups conflictuels..."
rm -f ./src/services_backup_*/partnerRequestProcessor.ts

# 4️⃣ Correction typage ONBOARD_REQUEST dans partnerRequestProcessor.ts
echo "🔧 Correction typage ONBOARD_REQUEST..."
sed -i 's/audit("ONBOARD_REQUEST".*/audit("ONBOARD_REQUEST" as AuditEvent, { uuid, decision, timestamp: new Date() });/' ./src/services/partnerRequestProcessor.ts

# 5️⃣ Création baseModel si manquant
if [ ! -f "./src/models/baseModel.ts" ]; then
    echo "💾 baseModel.ts manquant → création automatique..."
    cat <<EOL > ./src/models/baseModel.ts
export class BaseModel {
    id: string;
    createdAt: Date = new Date();
    updatedAt: Date = new Date();
}
EOL
fi

# 6️⃣ Vérification compilation TypeScript
echo "🧪 Vérification TypeScript..."
npx tsc --noEmit
if [ $? -eq 0 ]; then
    echo "🎉 Partner Onboarding OmniUtil – FIX FINAL COMPLET et compilable !"
else
    echo "⚠️ Erreurs TypeScript persistantes, vérifier manuellement."
fi
