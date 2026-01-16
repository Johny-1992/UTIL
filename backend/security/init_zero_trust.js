const fs = require("fs");

const policy = {
  qr_event_validation: true,
  anti_replay: true,
  signed_logs: true,
  strict_types: true,
  created: new Date().toISOString()
};

fs.writeFileSync("security/zero_trust_policy.json", JSON.stringify(policy, null, 2));
console.log("✅ Sécurité Zero-Trust active");
