#!/usr/bin/env node

// =======================
// OMNIUTIL UNIVERSE FUSION A+B
// =======================

const path = require("path");
const fs = require("fs");

// 📜 Charger ABI
const abiPath = path.resolve(__dirname, "../utils/omniutil_abi.json");
if (!fs.existsSync(abiPath)) {
    throw new Error(`❌ ABI Omniutil introuvable dans le projet : ${abiPath}`);
}
const rawAbi = require(abiPath);
const abi = rawAbi.abi || rawAbi;

console.log(`📜 ABI chargée depuis : ${abiPath}`);
console.log(`🔗 Contrat BSC : 0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1`);
console.log(`🧬 Fonctions détectées :`);
abi.forEach(f => f.type === "function" && console.log(" -", f.name));

// =======================
// Modules Runtime
// =======================
const { computeReward } = require("./reward_engine");
const { evaluatePartner } = require("./ai_runtime");
const { onQRScan } = require("./qr_entry");

// =======================
// Fusion A + B → simulation
// =======================

function runOmniutilUniverseSimulation() {
    // Simulation d'un scan QR d'un partenaire
    const partnerData = { name: "Airtel-RDC", subscribers: 5000000 };
    const qrEvent = onQRScan(partnerData);

    // Décision AI
    const decision = evaluatePartner(partnerData);

    // Calcul récompense sur consommation simulée
    const reward = computeReward(10, 0.05, 0.01); // 10 unités consommées, taux partenaire, facteur UTIL

    return { qr: qrEvent, decision, reward };
}

// =======================
// Lancement
// =======================
console.log("🌌 Lancement Omniutil UNIVERSE FUSION A+B...");
const result = runOmniutilUniverseSimulation();

console.log("🔳 QR EVENT →", result.qr);
console.log("🤖 AI DECISION →", result.decision);
console.log("🎯 REWARD →", result.reward, "UTIL");

console.log("🌕 Fusion A+B terminée ✅ L'Omniutil Universe est actif !");
