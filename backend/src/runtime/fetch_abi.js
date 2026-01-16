const fs = require("fs");
const path = require("path");
const { ethers } = require("ethers");

// RPC BSC (Mainnet)
const provider = new ethers.JsonRpcProvider("https://bsc-dataseed.binance.org/");

// Adresse du contrat
const contractAddress = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";

// Scan API ou autre moyen si nécessaire
async function fetchABI() {
  console.log("🌐 Récupération ABI depuis BSC...");

  // Si tu as l'API BscScan (optionnel)
  const apiKey = ""; // mettre ta clé BscScan ici si nécessaire

  const url = `https://api.bscscan.com/api?module=contract&action=getabi&address=${contractAddress}&apikey=${apiKey}`;
  const res = await fetch(url);
  const data = await res.json();

  if (data.status !== "1") throw new Error("❌ Impossible de récupérer ABI depuis BscScan");

  const abi = JSON.parse(data.result);

  // Sauvegarde locale
  const savePath = path.resolve(__dirname, "../abi/Omniutil.json");
  fs.mkdirSync(path.dirname(savePath), { recursive: true });
  fs.writeFileSync(savePath, JSON.stringify(abi, null, 2));

  console.log("✅ ABI sauvegardée localement :", savePath);
}

fetchABI().catch(console.error);
