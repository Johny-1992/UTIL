import { rewardRule } from "../orchestrator/rules";

export function calculateUTIL(
  spentUSD: number,
  rate: number,
  utilUsd: number
): number {
  return rewardRule(spentUSD, rate, utilUsd);
}
