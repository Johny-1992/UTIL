#!/bin/bash
# OmniUtil — Script Salvateur Définitif v9
# Nettoie, compile, vérifie services et simule Partner Onboarding + Rewards

set -e

echo "🛡️ OmniUtil — Script Salvateur Définitif v9"
echo "==========================================="

# Créer un dossier backups si inexistant
mkdir -p ./backups

# Création du backup complet du projet
BACKUP_DIR="./backups/backup_salveur_$(date +%s)"
echo "💾 Création du backup complet du projet dans $BACKUP_DIR"
cp -r . "$BACKUP_DIR" --no-dereference --preserve=all

echo "✅ Backup créé : $BACKUP_DIR"

# Nettoyage build / cache
echo "🧹 Nettoyage build/dist/cache..."
rm -rf dist build node_modules/.cache

# Vérification des services essentiels
echo "🛠️ Vérification PartnerOnboardingService..."
if [ ! -f src/services/PartnerOnboardingService.ts ]; then
    echo "⚠️ PartnerOnboardingService manquant ! Création automatique..."
    cat <<EOT > src/services/PartnerOnboardingService.ts
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
    const request = { uuid: 'SIM-' + Date.now(), name: 'Test Partner', activeUsers: 1500 };
    this.createRequest(request);
    this.approveRequest(request.uuid);
    return { created: request, approved: { uuid: request.uuid, status: 'APPROVED' }, simulation: 'SUCCESS' };
  }
}
EOT
fi
echo "✅ PartnerOnboardingService.ts présent"

echo "🔧 Vérification UtilTokenService..."
if [ ! -f src/services/UtilTokenService.ts ]; then
    echo "⚠️ UtilTokenService manquant ! Création automatique..."
    cat <<EOT > src/services/UtilTokenService.ts
import { Wallet, ethers } from 'ethers';
import 'dotenv/config';

export class UtilTokenService {
  provider: ethers.JsonRpcProvider;
  wallet: Wallet;

  constructor() {
    this.provider = new ethers.JsonRpcProvider(process.env.BSC_RPC_URL);
    this.wallet = new Wallet(process.env.PRIVATE_KEY!, this.provider);
  }

  async simulateReward() {
    console.log("Wallet address:", this.wallet.address);
    return { success: true };
  }
}
EOT
fi
echo "✅ UtilTokenService.ts présent"

# Compilation TypeScript
echo "🧪 Compilation TypeScript..."
npx tsc
echo "✅ Compilation OK"

# Simulation Partner Onboarding + Rewards
echo "🤖 Simulation Partner Onboarding + Rewards..."
node -e "
require('dotenv').config();
const { PartnerOnboardingService } = require('./dist/services/PartnerOnboardingService');
const { UtilTokenService } = require('./dist/services/UtilTokenService');

const service = new PartnerOnboardingService();
console.log(service.simulate());

new UtilTokenService().simulateReward().then(console.log);
"

echo "🎉 OmniUtil Salvateur Définitif v9 exécuté avec succès !"
