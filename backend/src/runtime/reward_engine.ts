export function computeReward(consumptionUSD: number, rewardRate: number, utilRate: number) {
  const rewardUSD = consumptionUSD * rewardRate;
  return rewardUSD / utilRate;
}
