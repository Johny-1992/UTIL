#!/bin/bash
echo "🚀 Lancement validation Partner Onboarding OmniUtil..."

# Backup temporaire pour sécurité
cp -r src/services src/services_backup_$(date +%s)
echo "💾 Backup temporaire créé"

# Étape 1 : Vérification modèles
echo "🔍 Vérification PartnerRequest Model..."
npx tsc src/models/partnerRequest.ts --noEmit
if [ $? -eq 0 ]; then echo "✅ PartnerRequest Model OK"; else echo "⚠️ Erreurs TS sur PartnerRequest Model"; fi

# Étape 2 : Vérification PartnerOnboardingService
echo "🔍 Vérification PartnerOnboardingService..."
npx tsc src/services/partnerOnboardingService.ts --noEmit
if [ $? -eq 0 ]; then echo "✅ PartnerOnboardingService OK"; else echo "⚠️ Erreurs TS sur PartnerOnboardingService"; fi

# Étape 3 : Vérification PartnerRequestProcessor
echo "🔍 Vérification PartnerRequestProcessor..."
npx tsc src/services/partnerRequestProcessor.ts --noEmit
if [ $? -eq 0 ]; then echo "✅ PartnerRequestProcessor OK"; else echo "⚠️ Erreurs TS sur PartnerRequestProcessor"; fi

# Étape 4 : Test logique PartnerRequestProcessor
echo "🧪 Test logique auto PartnerRequestProcessor..."
node -e "
const { processPartnerRequest } = require('./src/services/partnerRequestProcessor');
const { PartnerRequest } = require('./src/models/partnerRequest');

const testRequest = new PartnerRequest({
    uuid: 'test-uuid',
    activeUsers: 5000,
    reputationScore: 85,
    status: 'PENDING_AI'
});

processPartnerRequest(testRequest).then(() => {
    console.log('✅ Test PartnerRequestProcessor complet pour ONBOARD_REQUEST');
}).catch(err => {
    console.error('⚠️ Erreur test PartnerRequestProcessor :', err);
});
"

# Étape 5 : Vérification QR OmniUtil
echo "🔍 Vérification QR OmniUtil..."
if [ -f assets/qr/omnutil_qr.png ]; then
    echo "✅ QR OmniUtil présent : assets/qr/omnutil_qr.png"
else
    echo "⚠️ QR OmniUtil manquant"
fi

# Étape 6 : Compilation globale
echo "🧪 Compilation TS globale..."
npx tsc --noEmit
if [ $? -eq 0 ]; then echo "🎉 TS Compilation OK — Onboarding partenaire opérationnel"; else echo "⚠️ Erreurs TS détectées, vérifier manuellement"; fi
