#!/bin/bash
set -e

echo "🛡️ OmniUtil — Patch FINAL Simulation Partner Onboarding"
echo "====================================================="

SERVICE="src/services/PartnerOnboardingService.ts"

if ! grep -q "simulate()" "$SERVICE"; then
  echo "➕ Ajout méthode simulate() (logique métier réelle)"

  sed -i '/export class PartnerOnboardingService {/a\
\
  simulate() {\
    const mockRequest = {\
      uuid: \"SIM-\" + Date.now(),\
      name: \"Test Partner\",\
      activeUsers: 1500\
    } as any;\
\
    const created = this.createRequest(mockRequest);\
    const approved = this.approveRequest(created.uuid);\
\
    return {\
      created,\
      approved,\
      simulation: \"SUCCESS\"\
    };\
  }\
' "$SERVICE"

  echo "✅ Méthode simulate() ajoutée"
else
  echo "✅ Méthode simulate() déjà présente"
fi

echo "🧪 Recompilation TypeScript..."
rm -rf dist
npx tsc
echo "✅ Compilation OK"

echo "🤖 Test runtime Node (dist)..."
node -e "
const { PartnerOnboardingService } = require('./dist/services/PartnerOnboardingService');
const service = new PartnerOnboardingService();
console.log(JSON.stringify(service.simulate(), null, 2));
"

echo "🎉 Simulation Partner Onboarding VALIDÉE définitivement"
