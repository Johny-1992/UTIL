#!/bin/bash
echo "🚀 SIMULATION OMNIUTIL — DÉMARRAGE"

echo "1️⃣ Génération QR utilisateur"
node scripts/simulate_scan.js

echo "2️⃣ Validation IA de la consommation"
node scripts/simulate_ai_validation.js

echo "3️⃣ Interaction Smart Contract (mint UTIL)"
node scripts/simulate_contract.js

echo "4️⃣ Échange UTIL → USDT"
node scripts/simulate_exchange.js

echo "5️⃣ Transfert UTIL entre utilisateurs"
node scripts/simulate_transfer.js

echo "✅ SIMULATION COMPLÈTE TERMINÉE"
