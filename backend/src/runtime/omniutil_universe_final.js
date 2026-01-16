// src/runtime/omniutil_universe_final.js
const path = require("path");
const fs = require("fs");

// --- ABI Contract Loader ---
const abiPath = path.resolve(__dirname, "../utils/omniutil_abi.json");
if (!fs.existsSync(abiPath)) throw new Error("❌ ABI Omniutil introuvable dans le projet");

// On s'assure que 'abi' est bien un tableau, même si le JSON contient d'autres infos
const json = JSON.parse(fs.readFileSync(abiPath));
const abi = Array.isArray(json) ? json : json.abi;

const CONTRACT_ADDRESS = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";

console.log("📜 ABI chargée depuis :", abiPath);
console.log("🔗 Contrat BSC :", CONTRACT_ADDRESS);
console.log("🧬 Fonctions détectées :");
abi.filter(x => x.type === "function").forEach(f => console.log(" -", f.name));

// --- Import modules existants ---
const { computeReward } = require("./reward_engine");
const { evaluatePartner } = require("./ai_runtime");
const { onQRScan } = require("./qr_entry");
const { orchestrate } = require("./orchestrator");

// --- Partner Validation Intelligent ---
let validatePartner;
try {
    validatePartner = require("../api/partner_validation"); // si dispo
} catch {
    try {
        validatePartner = require("../onboard/partner_validation_fallback"); // fallback
    } catch {
        // Création d'un fallback simulé minimal
        validatePartner = (partner) => ({ status: "SIMULATED_ACCEPT", partner });
    }
}

// --- Omniutil Universe Simulation ---
function runSimulation() {
    const partnerData = { name: "Airtel-RDC", subscribers: 5000000 };

    const qr = onQRScan(partnerData);
    const decision = evaluatePartner(partnerData);
    const reward = computeReward(10, 0.05, 0.01); // Ex : 10 UTIL de base

    // Orchestration (si module dispo)
    orchestrate && orchestrate(partnerData);

    // Validation partenaire intelligente
    const validation = validatePartner(partnerData);

    return {
        qr,
        decision,
        reward,
        validation,
    };
}

// --- Lancement Simulation LIVE ---
console.log("🌌 OMNIUTIL UNIVERSE – Fusion LIVE démarrée");
const result = runSimulation();

console.log("🔳 QR EVENT →", result.qr);
console.log("🤖 AI DECISION →", result.decision);
console.log("🎯 REWARD →", result.reward, "UTIL");
console.log("✅ Partner Validation →", result.validation.status || result.validation);
console.log("🌕 OMNIUTIL UNIVERSE – Fusion LIVE terminée ✅");

// Export pour réutilisation si besoin
module.exports = { runSimulation };
