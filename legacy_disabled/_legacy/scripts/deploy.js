const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const OmniUtil = await hre.ethers.getContractFactory("OmniUtil");

  // Récupère les adresses depuis le fichier .env
  const creatorAddress = process.env.CREATOR_ADDRESS;
  const treasuryAddress = process.env.TREASURY_ADDRESS;

  // Déploie le contrat
  const omniUtil = await OmniUtil.deploy(creatorAddress, treasuryAddress);

  // Attend que le déploiement soit confirmé
  await omniUtil.waitForDeployment();

  console.log("OmniUtil déployé à l'adresse :", await omniUtil.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

