import hre from "hardhat";

async function main() {
  const { ethers } = hre;

  console.log("🚀 Déploiement OmniUtilCore...");

  const Factory = await ethers.getContractFactory("OmniUtilCore");
  const contract = await Factory.deploy();

  await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log("✅ Contrat déployé à :", address);
}

main().catch((err) => {
  console.error("❌ Erreur déploiement :", err);
  process.exit(1);
});
