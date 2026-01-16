function processConsumption(user, amountUSD, partner) {
  return {
    user,
    amountUSD,
    partner,
    timestamp: Date.now()
  };
}

module.exports = { processConsumption };
