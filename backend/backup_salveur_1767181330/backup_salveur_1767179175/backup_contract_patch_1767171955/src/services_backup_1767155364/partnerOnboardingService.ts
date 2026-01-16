import { PartnerRequest, partnerRequests } from "../models/partnerRequestModel";

export const createPartnerRequest = (request: Omit<PartnerRequest, 'id'|'status'|'createdAt'|'updatedAt'>) => {
  const id = 'p_' + Date.now();
  partnerRequests[id] = {
    ...request,
    id,
    status: 'PENDING_AI',
    createdAt: new Date(),
    updatedAt: new Date(),
  };
  return partnerRequests[id];
};

export const updatePartnerStatus = (id: string, status: PartnerRequest['status']) => {
  if (partnerRequests[id]) {
    partnerRequests[id].status = status;
    partnerRequests[id].updatedAt = new Date();
    return partnerRequests[id];
  }
  return null;
};

export const listPartnerRequests = () => Object.values(partnerRequests);
