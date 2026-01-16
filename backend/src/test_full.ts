import { ethers } from "ethers";

// Adresse du contrat
const CONTRACT_ADDRESS = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";

// ABI inline (exemple minimal, à remplacer par ton ABI complet)
const OmniUtilABI = [
  {
    "inputs": [],
    "name": "exampleFunction",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
];

// Provider par défaut (Ether mainnet)
const provider = new ethers.JsonRpcProvider("https://mainnet.infura.io/v3/YOUR_INFURA_KEY");

// Instance du contrat
const contract = new ethers.Contract(CONTRACT_ADDRESS, OmniUtilABI, provider);

async function main() {
  try {
    const result = await contract.exampleFunction();
    console.log("Résultat du contrat :", result.toString());
  } catch (error) {
    console.error("Erreur :", error);
  }
}

main();
