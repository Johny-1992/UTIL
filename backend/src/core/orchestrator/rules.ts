export function rewardRule(
  amountSpentUSD: number,
  rewardRate: number,
  utilUsdValue: number
): number {
  return (amountSpentUSD * rewardRate) / utilUsdValue;
}
