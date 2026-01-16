#!/bin/bash

# 1. Vérifier que le dossier contracts existe
if [ ! -d "../contracts" ]; then
  echo "❌ Erreur: Le dossier contracts/ est introuvable."
  exit 1
fi

# 2. Compiler le contrat
echo "Compilation du contrat OmniUtil..."
cd ~/omniutil/contracts || exit 1
npx hardhat compile || { echo "❌ Erreur: Échec de la compilation."; exit 1; }

# 3. Déployer en local (mode démo)
echo "Déploiement en local..."
DEPLOY_OUTPUT=$(npx hardhat run scripts/deploy_proxied.js --network localhost 2>&1)
DEPLOY_EXIT_CODE=$?
if [ $DEPLOY_EXIT_CODE -ne 0 ]; then
  echo "❌ Erreur: Échec du déploiement."
  echo "$DEPLOY_OUTPUT"
  exit 1
fi

# 4. Récupérer l'adresse du contrat
NEW_CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oP 'OmniUtil déployé à: \K0x[^\s]+')
if [ -z "$NEW_CONTRACT_ADDRESS" ]; then
  echo "❌ Erreur: Impossible de récupérer l'adresse du contrat."
  exit 1
fi

echo "Nouvelle adresse du contrat: $NEW_CONTRACT_ADDRESS"

# 5. Mettre à jour contracts.ts
echo "Mise à jour de contracts.ts..."
sed -i "s|OMNIUTIL_CONTRACT_ADDRESS = \".*\"|OMNIUTIL_CONTRACT_ADDRESS = \"$NEW_CONTRACT_ADDRESS\"|" ~/omniutil/backend/src/utils/contracts.ts

# 6. Créer le fichier de logs si inexistant
mkdir -p ~/omniutil/contracts
echo "OmniUtil déployé à: $NEW_CONTRACT_ADDRESS" > ~/omniutil/contracts/deploy_logs.txt

# 7. Redémarrer le backend
echo "Redémarrage du backend..."
cd ~/omniutil/backend || exit 1
if pm2 list | grep -q "omniutil-api"; then
  pm2 restart omniutil-api
else
  pm2 start "npm run start" --name omniutil-api
fi

echo "✅ Déploiement terminé ! Contrat déployé à: $NEW_CONTRACT_ADDRESS"
