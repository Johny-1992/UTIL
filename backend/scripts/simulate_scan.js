const crypto = require("crypto");

const qrPayload = {
  user: "USER_001",
  partner: "PARTNER_OMNIUTIL",
  timestamp: new Date().toISOString(),
  nonce: crypto.randomBytes(8).toString("hex")
};

console.log("📸 QR SCANNÉ AVEC SUCCÈS");
console.log(qrPayload);
