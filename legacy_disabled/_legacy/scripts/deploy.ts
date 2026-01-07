import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("🚀 Déploiement avec :", deployer.address);

  const OmniUtil = await ethers.getContractFactory("OmniUtil");
  const contract = await OmniUtil.deploy(
    deployer.address, // CREATOR
    deployer.address  // TREASURY
  );

  await contract.waitForDeployment();

  console.log("✅ OmniUtil déployé à :", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
