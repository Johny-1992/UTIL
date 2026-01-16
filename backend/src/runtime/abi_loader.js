const fs = require("fs");
const path = require("path");

function loadOmniutilABI() {
  const possiblePaths = [
    path.resolve(__dirname, "../abi/Omniutil.json"),
    path.resolve(__dirname, "../abi/omniutil.json"),
    path.resolve(__dirname, "../../abi/Omniutil.json"),
    path.resolve(__dirname, "../../contracts/Omniutil.json"),
    path.resolve(__dirname, "../../build/Omniutil.json"),
    path.resolve(__dirname, "../../artifacts/Omniutil.json")
  ];

  for (const p of possiblePaths) {
    if (fs.existsSync(p)) {
      console.log("📜 ABI chargée depuis :", p);
      return JSON.parse(fs.readFileSync(p, "utf8"));
    }
  }

  throw new Error("❌ ABI Omniutil introuvable dans le projet");
}

module.exports = { loadOmniutilABI };
