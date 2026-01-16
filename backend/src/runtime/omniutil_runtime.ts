import { evaluatePartner } from "../core/ai/ai_coordinator";
import { calculateUTIL } from "../core/rewards/reward_engine";

export function processPartnerRequest(partner: any) {
  return evaluatePartner(partner);
}

export function processReward(spentUSD: number, rate: number, utilUsd: number) {
  return calculateUTIL(spentUSD, rate, utilUsd);
}
