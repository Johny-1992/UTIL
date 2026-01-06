import { BaseModel } from './baseModel.js';

export type PartnerRequestStatus = 'PENDING_AI' | 'AUTO_ACCEPTED' | 'AUTO_REJECTED' | 'WAITING_SIGNER' | 'APPROVED';

export interface PartnerRequest extends BaseModel {
  uuid: string;
  name: string;
  activeUsers: number;
  reputationScore: number;
  status: PartnerRequestStatus;
  requestedAt: Date;
}

export const PartnerRequestSchema = {
  uuid: String,
  name: String,
  activeUsers: Number,
  reputationScore: Number,
  status: String,
  requestedAt: Date,
};
