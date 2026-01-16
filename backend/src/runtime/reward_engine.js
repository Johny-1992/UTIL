module.exports.computeReward = function(consumptionUSD, rewardRate, utilRate) {
  const rewardUSD = consumptionUSD * rewardRate;
  return rewardUSD / utilRate;
};
