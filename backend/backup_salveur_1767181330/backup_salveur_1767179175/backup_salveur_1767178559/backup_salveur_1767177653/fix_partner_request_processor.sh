#!/bin/bash
echo "🧯 Correction Partner Request Processor OmniUtil..."

# Sauvegarde
cp src/services/partnerRequestProcessor.ts src/services/partnerRequestProcessor.ts.bak
echo "💾 Backup créé : partnerRequestProcessor.ts.bak"

# Réécriture safe du fichier
cat > src/services/partnerRequestProcessor.ts << 'EOF'
import { PartnerRequest, partnerRequests } from "../models/partnerRequestModel";
import { audit } from "../utils/auditLogger";

type PartnerDecision = "PENDING_AI" | "AUTO_ACCEPTED" | "AUTO_REJECTED" | "WAITING_SIGNER" | "APPROVED";

export const processPartnerRequest = (uuid: string) => {
  const request: PartnerRequest | undefined = partnerRequests[uuid];
  if (!request) {
    throw new Error("Partner request not found");
  }

  // Analyse AI Coordinator (logique simple pour l'instant)
  let decision: PartnerDecision =
      request.activeUsers > 1000 ? "AUTO_ACCEPTED" :
      request.activeUsers < 100 ? "AUTO_REJECTED" :
      "PENDING_AI";

  request.status = decision;

  // Audit TS-safe
  audit("ONBOARD_REQUEST", { uuid, decision, timestamp: new Date() });

  // Notification wallet partnersigner (mock)
  console.log(\`🔔 Notification partnersigner: Request \${uuid} => \${decision}\`);

  return { uuid, decision };
};
EOF

# Compilation TS
echo "🧪 Vérification TypeScript..."
npx tsc --noEmit

if [ $? -eq 0 ]; then
  echo "🎉 Partner Request Processor corrigé et compilé TS OK"
else
  echo "⚠️ Erreurs TS détectées, vérifier manuellement"
fi
