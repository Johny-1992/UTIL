export async function getPartnerRewardRate(partnerId: string) {
  const partners = { p1: 0.05, p2: 0.10 };
  return partners[partnerId];
}
