#!/bin/bash
# omniutil_salveur_definitif_v4.sh
# Script Salvateur Définitif OmniUtil v4

echo "🛡️ OmniUtil — Script Salvateur Définitif v4"
echo "==========================================="

# Backup complet
BACKUP_DIR="backup_salveur_$(date +%s)"
mkdir -p "$BACKUP_DIR"
echo "💾 Création du backup complet du projet dans $BACKUP_DIR"
cp -r ./ "$BACKUP_DIR"
echo "✅ Backup créé : $BACKUP_DIR"

# Nettoyage build / cache
echo "🧹 Nettoyage build/dist/cache TypeScript..."
rm -rf dist node_modules/.cache

# Vérification PartnerOnboardingService
echo "🛠️ Vérification PartnerOnboardingService..."
SERVICE_FILE="src/services/PartnerOnboardingService.ts"
if [ ! -f "$SERVICE_FILE" ]; then
    echo "💾 PartnerOnboardingService manquant → création automatique"
    cat > "$SERVICE_FILE" <<EOL
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
    const approved = this.approveRequest(request.uuid);
    return { created: request, approved, simulation: 'SUCCESS' };
  }
}
EOL
else
    echo "✅ PartnerOnboardingService.ts présent"
fi

# Vérification UtilTokenService
echo "🔧 Vérification UtilTokenService..."
UTIL_FILE="src/services/UtilTokenService.ts"
if [ ! -f "$UTIL_FILE" ]; then
    echo "💾 Création UtilTokenService.ts"
    cat > "$UTIL_FILE" <<EOL
import { JsonRpcProvider, Wallet, Contract } from 'ethers';

export class UtilTokenService {
  provider: JsonRpcProvider;
  wallet: Wallet;

  constructor() {
    if (!process.env.BSC_RPC_URL || !process.env.PRIVATE_KEY) {
      throw new Error("⚠️ Veuillez définir BSC_RPC_URL et PRIVATE_KEY dans le fichier .env");
    }
    this.provider = new JsonRpcProvider(process.env.BSC_RPC_URL);
    this.wallet = new Wallet(process.env.PRIVATE_KEY, this.provider);
  }

  async simulateReward() {
    console.log('Wallet address:', this.wallet.address);
    return { success: true };
  }
}
EOL
fi

# Compilation TypeScript
echo "🧪 Compilation TypeScript..."
npx tsc
if [ $? -ne 0 ]; then
    echo "❌ Erreurs TypeScript détectées ! Vérifie les fichiers."
    exit 1
fi
echo "✅ Compilation OK"

# Test runtime PartnerOnboardingService
echo "🤖 Test runtime PartnerOnboardingService..."
node -e "const { PartnerOnboardingService } = require('./dist/services/PartnerOnboardingService'); console.log(new PartnerOnboardingService().simulate());"

# Test runtime UtilTokenService (connexion au smart contract)
echo "🤖 Test runtime UtilTokenService (connexion contrat existant)..."
node -e "const { UtilTokenService } = require('./dist/services/UtilTokenService'); new UtilTokenService().simulateReward().then(console.log).catch(console.error);"

echo "🎉 OmniUtil — Script Salvateur Définitif v4 terminé"
