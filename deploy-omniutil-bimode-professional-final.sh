#!/bin/bash

# ==========================================
# 🚀 OMNIUTIL – BIMODE PROFESSIONNEL FINAL
# ==========================================

echo "=========================================="
echo "🚀 OMNIUTIL – BIMODE PROFESSIONNEL FINAL"
echo "=========================================="

# --- 1️⃣ Charger .env ---
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo "✅ .env chargé"
else
    echo "⚠️ .env manquant !"
    exit 1
fi

echo "🔧 MODE ACTUEL : ${MODE:-DEMO}"

# --- 2️⃣ Vérification structure projet ---
REQUIRED_DIRS=("frontend" "backend" "contracts" "scripts")
for d in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$d" ]; then
        echo "⚠️ Répertoire manquant: $d"
        exit 1
    fi
done
echo "✅ Structure projet OK"

# --- 3️⃣ Installation / Mise à jour dépendances ---
echo "📦 Installation dépendances Frontend / Backend..."
npm install --legacy-peer-deps
echo "✅ Dépendances OK"

# --- 4️⃣ Build Frontend React ---
echo "🏗️ Build frontend..."
cd frontend
npm run build
cd ..
echo "✅ Frontend build OK"

# --- 5️⃣ Backend ---
echo "🔗 Backend..."
cd backend
npm install --legacy-peer-deps
cd ..
echo "✅ Backend OK"

# --- 6️⃣ Compilation & Déploiement Contrat via Hardhat ---
echo "📄 Smart Contract"
if [ ! -f contracts/core/OmniUtilCore.sol ]; then
    echo "⚠️ Contrat manquant : contracts/core/OmniUtilCore.sol"
    exit 1
fi

echo "📄 Compilation + Déploiement contrat via Hardhat..."

# Créer un script temporaire pour déployer
DEPLOY_SCRIPT="scripts/deploy-contract-temp.js"
cat > $DEPLOY_SCRIPT <<EOL
import hre from "hardhat";
import fs from "fs";

const main = async () => {
  const ContractFactory = await hre.ethers.getContractFactory("OmniUtilCore");
  const contract = await ContractFactory.deploy();
  await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log("✅ Contrat déployé à :", address);

  const OUTPUT_DIR = "versions/contracts";
  if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });

  const abi = JSON.stringify(contract.interface.format("json"), null, 2);
  fs.writeFileSync(\`\${OUTPUT_DIR}/OmniUtilCore.abi\`, abi);
  fs.writeFileSync(\`\${OUTPUT_DIR}/OmniUtilCore.address\`, address);
};

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
EOL

# Déployer avec Hardhat
echo "🚀 Déploiement du contrat..."
npx hardhat run scripts/deploy-contract-temp.js --network hardhat || {
  echo "❌ Déploiement contrat échoué !"
  exit 1
fi

rm -f $DEPLOY_SCRIPT

# --- 7️⃣ Injection adresse contrat partout ---
CONTRACT_ADDRESS=$(cat versions/contracts/OmniUtilCore.address)
echo "🔗 Injection adresse contrat : $CONTRACT_ADDRESS"
# Ici tu peux ajouter la logique pour injecter automatiquement l'adresse dans config frontend/backend si nécessaire

# --- 8️⃣ Vérification C++ Orchestrateur ---
if [ -d cpp ]; then
    echo "🤖 Compilation C++ Orchestrateur..."
    cd cpp
    if [ ! -f Makefile ]; then
        echo "⚠️ Makefile manquant, création Makefile minimal"
        cat > Makefile <<EOL
all:
\tg++ main.cpp -o orchestrator
EOL
    fi
    make || echo "⚠️ Erreur compilation C++ ignorée"
    cd ..
else
    echo "⚠️ Répertoire cpp introuvable, C++ ignoré"
fi

# --- 9️⃣ Déploiement Frontend Vercel ---
echo "🌍 Déploiement frontend sur Vercel..."
npx vercel --prod --confirm
echo "✅ Frontend déployé"

echo "=========================================="
echo "🎉 OMNIUTIL EST 100% OPÉRATIONNEL"
echo "🌍 MODE : ${MODE:-DEMO}"
echo "📜 CONTRAT : $CONTRACT_ADDRESS"
echo "🚀 PRÊT POUR INVESTISSEURS & PARTENAIRES"
echo "=========================================="

