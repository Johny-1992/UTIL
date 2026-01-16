export type PartnerDecision = "ACCEPTED" | "REJECTED" | "PENDING";

export function evaluatePartner(partner: {
  name: string;
  ecosystem: string;
  activeUsers: number;
}): PartnerDecision {

  if (partner.activeUsers > 1000000) return "ACCEPTED";
  if (partner.activeUsers < 10000) return "REJECTED";
  return "PENDING";
}
