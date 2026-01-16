#!/bin/bash
echo "🛠️  Correction finale AuditEvent pour Partner Onboarding..."

# Backup du fichier concerné
cp src/services/partnerRequestProcessor.ts src/services/partnerRequestProcessor.ts.bak
echo "💾 Backup créé : partnerRequestProcessor.ts.bak"

# Remplacer l'import AuditEvent par celui du auditLogger
sed -i "s|import { AuditEvent }.*|import { AuditEvent } from '../utils/auditLogger';|" src/services/partnerRequestProcessor.ts
echo "✅ Import AuditEvent aligné avec auditLogger"

# Forcer le typage 'as AuditEvent' sur ONBOARD_REQUEST
sed -i "s/audit(\"ONBOARD_REQUEST\"/audit(\"ONBOARD_REQUEST\" as AuditEvent/g" src/services/partnerRequestProcessor.ts
echo "✅ Typage ONBOARD_REQUEST corrigé en 'as AuditEvent'"

# Vérification TypeScript
echo "🧪 Vérification TypeScript..."
npx tsc --noEmit
if [ $? -eq 0 ]; then
    echo "🎉 AuditEvent ONBOARD_REQUEST corrigé et compilation TS OK"
else
    echo "⚠️ Erreurs TS persistantes, vérifier manuellement"
fi
