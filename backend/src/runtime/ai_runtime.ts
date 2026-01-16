export function evaluatePartner(partner: any) {
  if (!partner || !partner.name || !partner.subscribers) {
    return "REJECTED";
  }
  if (partner.subscribers > 1000000) {
    return "AUTO_ACCEPTED";
  }
  return "PENDING";
}
