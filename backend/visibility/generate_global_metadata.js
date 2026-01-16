const fs = require("fs");

const meta = {
  name: "Omniutil",
  description: "Global reward infrastructure for real-world consumption",
  contract_chain: "BSC",
  utility: ["Rewards", "Services", "USDT Exchange"],
  access: "Universal QR",
  version: "1.0"
};

fs.writeFileSync("visibility/omniutil.json", JSON.stringify(meta, null, 2));
console.log("✅ Metadata mondiale générée");
