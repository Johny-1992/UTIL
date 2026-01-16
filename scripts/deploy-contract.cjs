const fs = require("fs");
const solc = require("solc");
const { ethers } = require("ethers");
require("dotenv").config();

const CONTRACT_PATH = "contracts/core/OmniUtilCore.sol";
const OUTPUT_DIR = "versions/contracts";

if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

// 1️⃣ Lire le contrat
const source = fs.readFileSync(CONTRACT_PATH, "utf8");

// 2️⃣ Compilation solc-js
const input = {
  language: "Solidity",
  sources: {
    "OmniUtilCore.sol": { content: source }
  },
  settings: {
    outputSelection: {
      "*": {
        "*": ["abi", "evm.bytecode"]
      }
    }
  }
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));

if (output.errors) {
  for (const err of output.errors) {
    if (err.severity === "error") {
      console.error(err.formattedMessage);
      process.exit(1);
    }
  }
}

const contract = output.contracts["OmniUtilCore.sol"]["OmniUtilCore"];
const abi = contract.abi;
const bytecode = contract.evm.bytecode.object;

// 3️⃣ Sauvegarde ABI & BIN
fs.writeFileSync(`${OUTPUT_DIR}/OmniUtilCore.abi`, JSON.stringify(abi, null, 2));
fs.writeFileSync(`${OUTPUT_DIR}/OmniUtilCore.bin`, bytecode);

// 4️⃣ Provider & wallet
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// 5️⃣ Déploiement
(async () => {
  const factory = new ethers.ContractFactory(abi, bytecode, wallet);
  const contract = await factory.deploy();
  await contract.waitForDeployment();

  const address = await contract.getAddress();

  fs.writeFileSync(`${OUTPUT_DIR}/OmniUtilCore.address`, address);

  console.log("✅ Contrat déployé à :", address);
})();
