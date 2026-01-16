const { evaluatePartner } = require('./ai_engine');

function onQRScan(ecosystemInfo) {
  console.log("📸 QR OmniUtil scanné :", ecosystemInfo.name);

  const result = evaluatePartner(ecosystemInfo);

  if (result.approved) {
    console.log("✅ Partenaire accepté automatiquement");
  } else {
    console.log("⚠️ Validation humaine requise (PartnerSigner)");
  }

  return result;
}

module.exports = { onQRScan };
