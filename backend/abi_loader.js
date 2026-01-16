// src/runtime/abi_loader.js
const fs = require("fs");

function loadAbi(path) {
  const raw = JSON.parse(fs.readFileSync(path, "utf-8"));

  // Cas 1 : ABI direct
  if (Array.isArray(raw)) return raw;

  // Cas 2 : { abi: [...] }
  if (Array.isArray(raw.abi)) return raw.abi;

  // Cas 3 : { output: { abi: [...] } }
  if (raw.output && Array.isArray(raw.output.abi)) return raw.output.abi;

  // Cas 4 : Etherscan-like
  if (raw.result && Array.isArray(raw.result)) return raw.result;

  throw new Error("Format ABI non reconnu");
}

module.exports = { loadAbi };
