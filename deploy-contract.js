import hre from "hardhat";
import fs from "fs";

const main = async () => {
  const ContractFactory = await hre.ethers.getContractFactory("OmniUtilCore");
  const contract = await ContractFactory.deploy();
  await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log("✅ Contrat déployé à :", address);

  const OUTPUT_DIR = "versions/contracts";
  if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });

  const abi = JSON.stringify(contract.interface.format("json"), null, 2);
  fs.writeFileSync(`${OUTPUT_DIR}/OmniUtilCore.abi`, abi);
  fs.writeFileSync(`${OUTPUT_DIR}/OmniUtilCore.address`, address);
};

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
