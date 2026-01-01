export function onboardPartner(partner: any) {
  if (partner.score >= 80) {
    return { status: "accepted", partner };
  }
  return { status: "rejected", partner };
}
