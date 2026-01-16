"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
// test_full.ts
const axios_1 = __importDefault(require("axios"));
const ethers_1 = require("ethers");
const omniutil_abi_json_1 = __importDefault(require("./src/utils/omniutil_abi.json"));
// ----------------------
// CONFIGURATION
// ----------------------
const OMNIUTIL_CONTRACT_ADDRESS = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";
// Provider JSON-RPC
const provider = new ethers_1.JsonRpcProvider("http://127.0.0.1:8545");
// Création du contrat OmniUtil
const omniUtilContract = new ethers_1.Contract(OMNIUTIL_CONTRACT_ADDRESS, omniutil_abi_json_1.default.abi, provider);
// Endpoints Express
const endpoints = {
    health: "http://127.0.0.1:8080/health",
    aiStatus: "http://127.0.0.1:8080/api/ai/status",
};
// ----------------------
// FONCTIONS UTILITAIRES
// ----------------------
async function testEndpoint(name, url) {
    try {
        const response = await axios_1.default.get(url);
        console.log(`✅ ${name} response:`, response.data);
    }
    catch (err) {
        console.error(`❌ ${name} error:`, err.message || err);
    }
}
async function testContract() {
    console.log("\n🚀 Test du contrat OmniUtil...");
    try {
        if ("totalSupply" in omniUtilContract) {
            const totalSupply = await omniUtilContract.totalSupply();
            console.log("Contract totalSupply:", totalSupply.toString());
        }
        if ("owner" in omniUtilContract) {
            const owner = await omniUtilContract.owner();
            console.log("Contract owner:", owner);
        }
        console.log("✅ Contrat testé avec succès !");
    }
    catch (err) {
        console.error("❌ Erreur contrat:", err.message || err);
    }
}
// ----------------------
// MAIN
// ----------------------
async function main() {
    console.log("🔹 Démarrage des tests full moon...");
    await testEndpoint("Health endpoint", endpoints.health);
    await testEndpoint("AI Status endpoint", endpoints.aiStatus);
    await testContract();
    console.log("\n🌕 Full Moon script terminé !");
}
main();
