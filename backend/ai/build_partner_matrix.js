const fs = require("fs");

const matrix = {
  TELCO: {
    min_subscribers: 100000,
    auto_accept: true,
    reward_cap_percent: 8
  },
  BANK: {
    min_subscribers: 50000,
    auto_accept: false
  },
  RETAIL: {
    min_subscribers: 1000,
    auto_accept: true
  }
};

fs.writeFileSync("ai/partner_matrix.json", JSON.stringify(matrix, null, 2));
console.log("✅ Partner Decision Matrix générée");
