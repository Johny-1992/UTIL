#!/bin/bash
echo "🛡️  OmniUtil — Script Salvateur Définitif v7"
echo "==========================================="

# --------------------------
# Création du backup
# --------------------------
mkdir -p backups
TS=$(date +%s)
BACKUP_DIR="./backups/backup_salveur_$TS"
echo "💾 Création du backup complet du projet dans $BACKUP_DIR"
rsync -a --exclude "backups" ./ "$BACKUP_DIR"
echo "✅ Backup créé : $BACKUP_DIR"

# --------------------------
# Nettoyage build/dist/cache
# --------------------------
echo "🧹 Nettoyage build/dist/cache TypeScript..."
rm -rf dist node_modules/.cache

# --------------------------
# Vérification PartnerOnboardingService
# --------------------------
echo "🛠️ Vérification PartnerOnboardingService..."
if [ ! -f src/services/PartnerOnboardingService.ts ]; then
  echo "💾 PartnerOnboardingService.ts manquant → création automatique"
  cat <<EOL > src/services/PartnerOnboardingService.ts
import { PartnerRequest } from '../models/partnerRequest';

export class PartnerOnboardingService {
  createRequest(request: PartnerRequest) {
    console.log('Partner request created:', request);
    return request;
  }

  approveRequest(uuid: string) {
    console.log('Partner request approved:', uuid);
    return { uuid, status: 'APPROVED' };
  }

  rejectRequest(uuid: string) {
    console.log('Partner request rejected:', uuid);
    return { uuid, status: 'REJECTED' };
  }

  simulate() {
    const testRequest = { uuid: 'SIM-' + Date.now(), name: 'Test Partner', activeUsers: 1500 };
    this.createRequest(testRequest);
    this.approveRequest(testRequest.uuid);
    return { created: testRequest, approved: { uuid: testRequest.uuid, status: 'APPROVED' }, simulation: 'SUCCESS' };
  }
}
EOL
fi
echo "✅ PartnerOnboardingService.ts présent"

# --------------------------
# Vérification UtilTokenService
# --------------------------
echo "🔧 Vérification UtilTokenService..."
if [ -f src/services/UtilTokenService.ts ]; then
  echo "💾 Patch UtilTokenService.ts pour compatibilité ethers v6..."
  sed -i 's|ethers\.providers\.JsonRpcProvider|ethers\.JsonRpcProvider|' src/services/UtilTokenService.ts
fi

# --------------------------
# Compilation TypeScript
# --------------------------
echo "🧪 Compilation TypeScript..."
npx tsc
if [ $? -ne 0 ]; then
  echo "❌ Erreurs TypeScript détectées ! Vérifie les fichiers."
  exit 1
fi
echo "✅ Compilation OK"

# --------------------------
# Simulation runtime Partner Onboarding
# --------------------------
echo "🤖 Simulation Partner Onboarding..."
node -e "require('dotenv').config(); const { PartnerOnboardingService } = require('./dist/services/PartnerOnboardingService'); const service = new PartnerOnboardingService(); console.log(service.simulate());"

# --------------------------
# Connexion au Smart Contract OmniUtil (BSC Testnet)
# --------------------------
echo "🔗 Connexion au Smart Contract OmniUtil sur BSC Testnet..."
node -e "
require('dotenv').config();
const { UtilTokenService } = require('./dist/services/UtilTokenService');

(async () => {
  try {
    const service = new UtilTokenService();
    const result = await service.simulateReward();
    console.log('💰 Simulation reward:', result);
  } catch (err) {
    console.error('❌ Erreur simulation reward:', err.message);
  }
})();
"

echo "🎉 Script Salvateur Définitif v7 terminé !"
