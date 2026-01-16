const orchestrator = require("./orchestrator");
const { onQRScan } = require("./qr_entry");
const { evaluatePartner } = require("./ai_runtime");
const { computeReward } = require("./reward_engine");

function fallbackSimulation() {
  const partner = { name: "Airtel-RDC", subscribers: 5000000 };

  return {
    qr: onQRScan(partner),
    decision: evaluatePartner(partner),
    reward: computeReward(10, 0.05, 0.01)
  };
}

function runSimulation() {
  // Cas 1 : orchestrator expose déjà runSimulation
  if (typeof orchestrator.runSimulation === "function") {
    return orchestrator.runSimulation();
  }

  // Cas 2 : orchestrator est une fonction
  if (typeof orchestrator === "function") {
    return orchestrator();
  }

  // Cas 3 : fallback logique mère
  return fallbackSimulation();
}

module.exports = {
  runSimulation
};
