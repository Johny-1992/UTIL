const hre = require("hardhat");

async function main() {
  const CREATOR = "0x40BB46B9D10Dd121e7D2150EC3784782ae648090";
  const TREASURY = "0x75b6F35508a073c12B85a6079F1005a4139cb850";

  const OmniUtil = await hre.ethers.getContractFactory("OmniUtil");
  const omniUtil = await OmniUtil.deploy(CREATOR, TREASURY);
  await omniUtil.deployed();
  console.log("OmniUtil déployé à:", omniUtil.address);

  // Sauvegarder l'adresse dans un fichier
  const fs = require('fs');
  fs.writeFileSync('deploy_logs.txt', `OmniUtil déployé à: ${omniUtil.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
