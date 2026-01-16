#!/usr/bin/env node

// =======================
// OMNIUTIL UNIVERSE FUSION 1→5 – SCRIPT ULTIME
// =======================

const path = require("path");
const fs = require("fs");

// -----------------------
// Charger l'ABI et Contrat BSC
// -----------------------
const abiPath = path.resolve(__dirname, "../utils/omniutil_abi.json");
if (!fs.existsSync(abiPath)) {
    throw new Error(`❌ ABI Omniutil introuvable : ${abiPath}`);
}
const rawAbi = require(abiPath);
const abi = rawAbi.abi || rawAbi;
const contractAddress = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";

console.log(`📜 ABI chargée depuis : ${abiPath}`);
console.log(`🔗 Contrat BSC : ${contractAddress}`);
console.log(`🧬 Fonctions détectées :`);
abi.forEach(f => f.type === "function" && console.log(" -", f.name));

// -----------------------
// Modules Runtime
// -----------------------
const { computeReward } = require("./reward_engine");
const { evaluatePartner } = require("./ai_runtime");
const { onQRScan } = require("./qr_entry");
const { validatePartner } = require("./partner_validation");
const { orchestrate } = require("./orchestrator");

// -----------------------
// Simulation Partenaire
// -----------------------
const partners = [
    { name: "Airtel-RDC", subscribers: 5000000 },
    { name: "Canal+", subscribers: 1200000 },
    { name: "Supermarche-X", subscribers: 30000 },
    { name: "Hotel-Y", subscribers: 500 },
    { name: "Casino-Z", subscribers: 1500 }
];

function runOmniutilUniverse() {
    const results = [];

    partners.forEach(p => {
        const qr = onQRScan(p);
        const aiDecision = evaluatePartner(p);
        const partnerValidation = validatePartner(p);
        const orchestratorDecision = orchestrate(p, aiDecision, partnerValidation);

        const reward = computeReward(
            p.subscribers * 0.002,  // consommation simulée
            0.05,                     // taux récompense partenaire
            0.01                      // facteur UTIL
        );

        results.push({
            partner: p.name,
            qr,
            aiDecision,
            partnerValidation,
            orchestratorDecision,
            reward
        });
    });

    return results;
}

// -----------------------
// Lancement
// -----------------------
console.log("🌌 Lancement OMNIUTIL UNIVERSE FUSION 1→5...");
const simulation = runOmniutilUniverse();

simulation.forEach(r => {
    console.log("\n-----------------------------------------");
    console.log(`🔳 QR EVENT →`, r.qr);
    console.log(`🤖 AI DECISION →`, r.aiDecision);
    console.log(`✅ Partner Validation →`, r.partnerValidation);
    console.log(`⚙️ Orchestrator Decision →`, r.orchestratorDecision);
    console.log(`🎯 REWARD →`, r.reward, "UTIL");
});

console.log("\n🌕 Fusion 1→5 terminée ✅ Omniutil Universe est FULLY OPERATIONAL !");
