export interface Partner {
  rewardRate: number;
}

export const partners: Record<string, Partner> = {
  p1: { rewardRate: 0.1 },
  p2: { rewardRate: 0.2 }
};

export const getPartnerRewardRate = (partnerId: string): number =>
  partners[partnerId]?.rewardRate ?? 0;
