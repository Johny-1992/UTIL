#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

// --- Chargement ABI ---
const abiPath = path.resolve(__dirname, "../utils/omniutil_abi.json");
const abi = JSON.parse(fs.readFileSync(abiPath, "utf8"));
console.log("📜 ABI chargée :", abiPath);

// --- Contrat ---
const CONTRACT_ADDRESS = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";
console.log("🔗 Contrat BSC :", CONTRACT_ADDRESS);

// --- QR EVENT ---
const qrEvent = {
    type: "PARTNER_REQUEST",
    payload: { name: "Airtel-RDC", subscribers: 5000000 },
    timestamp: Date.now()
};
console.log("🔳 QR EVENT →", qrEvent);

// --- AI COORDINATEUR ---
function aiDecisionEngine(event) {
    if (event.payload.subscribers > 1000000) return "AUTO_ACCEPTED";
    if (event.payload.subscribers > 100000) return "PENDING";
    return "REJECTED";
}

const aiDecision = aiDecisionEngine(qrEvent);
console.log("🤖 AI DECISION →", aiDecision);

// --- Reward brut ---
let reward = 50;
if (aiDecision === "REJECTED") reward = 0;
if (!Number.isFinite(reward)) reward = 0;

console.log("🎯 REWARD (raw) →", reward, "UTIL");

// --- ORCHESTRATEUR ---
function orchestrate(event, decision, reward) {
    const binPath = path.resolve(__dirname, "../orchestrator/orchestrator_bin");

    try {
        if (!fs.existsSync(binPath)) throw new Error("BIN_MISSING");

        const output = execSync(
            `${binPath} '${JSON.stringify(event)}' '${decision}' ${reward}`,
            { stdio: "pipe" }
        ).toString().trim();

        console.log("🧠 Orchestrateur C++ →", output);
        const parts = output.split(" ");
        return {
            decision: parts[1],
            reward: Number(parts[2])
        };

    } catch (e) {
        console.warn("⚠️ Fallback orchestrateur simulé");
        return { decision, reward };
    }
}

const result = orchestrate(qrEvent, aiDecision, reward);
console.log("✅ Partner Validation →", result);

// --- LOGS ---
const logsDir = path.resolve(__dirname, "../logs");
if (!fs.existsSync(logsDir)) fs.mkdirSync(logsDir, { recursive: true });

const logFile = path.join(logsDir, "omniutil_live_" + Date.now() + ".log");
fs.writeFileSync(logFile, JSON.stringify({ qrEvent, result }, null, 2));

console.log("📂 Logs sauvegardés dans :", logFile);
console.log("🌕 OMNIUTIL UNIVERSE – Fusion LIVE terminée ✅");
