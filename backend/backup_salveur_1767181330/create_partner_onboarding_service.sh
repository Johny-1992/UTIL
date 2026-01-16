#!/bin/bash
# create_partner_onboarding_service.sh
# Crée PartnerOnboardingService minimal pour OmniUtil

SERVICE_FILE="src/services/PartnerOnboardingService.ts"
mkdir -p src/services

if [[ ! -f "$SERVICE_FILE" ]]; then
cat <<EOT > $SERVICE_FILE
import { PartnerRequest } from "../models/partnerRequest";

export class PartnerOnboardingService {
    static onboardPartner(request: PartnerRequest) {
        console.log(\`Partner \${request.name} onboarding initiated.\`);
        request.status = "WAITING_SIGNER";
        return request;
    }
}
EOT
    echo "✅ PartnerOnboardingService créé : $SERVICE_FILE"
else
    echo "ℹ️ PartnerOnboardingService déjà présent"
fi
