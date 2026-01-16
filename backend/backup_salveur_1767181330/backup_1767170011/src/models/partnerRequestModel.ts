export interface PartnerRequest {
  id: string;
  name: string;
  country: string;
  type: 'telco' | 'ecommerce' | 'streaming' | 'other';
  activeUsers: number;
  rewardRate: number; // % en UTIL
  wallet: string;
  status: 'PENDING_AI' | 'AUTO_ACCEPTED' | 'AUTO_REJECTED' | 'WAITING_SIGNER' | 'APPROVED';
  createdAt: Date;
  updatedAt: Date;
}

export const partnerRequests: Record<string, PartnerRequest> = {};
