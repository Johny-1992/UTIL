import { ethers } from "hardhat";
import fs from "fs";
async function main() {
  console.log("🚀 Déploiement OmniUtilCore (Hardhat v3 + viem)");

  // 1️⃣ Récupération du ContractFactory
  const OmniUtilCore = await ethers.getContractFactory("OmniUtilCore");

  // 2️⃣ Déploiement du contrat
  const contract = await OmniUtilCore.deploy(
    process.env.TREASURY_ADDRESS,
    process.env.AI_COORDINATOR
  );

  await contract.deployed();

  console.log("✅ Contrat déployé à :", contract.target || contract.address);

  // 3️⃣ Sauvegarder l’adresse pour le backend
  import fs from "fs";
  fs.writeFileSync(
    "./environments/contract_address.env",
    `CONTRACT_ADDRESS=${contract.address}\n`
  );

  console.log("📦 Adresse sauvegardée dans environments/contract_address.env");
}

main().catch((error) => {
  console.error("❌ Erreur de déploiement :", error);
  process.exit(1);
});
