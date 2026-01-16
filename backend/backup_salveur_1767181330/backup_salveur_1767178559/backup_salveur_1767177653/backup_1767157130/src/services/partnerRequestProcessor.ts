import { audit, AuditEvent } from '../utils/auditLogger';
import { PartnerRequest, partnerRequests } from "../models/partnerRequestModel";

type PartnerDecision = "PENDING_AI" | "AUTO_ACCEPTED" | "AUTO_REJECTED" | "WAITING_SIGNER" | "APPROVED";

export const processPartnerRequest = (uuid: string) => {
  const request: PartnerRequest | undefined = partnerRequests[uuid];
  if (!request) {
    throw new Error("Partner request not found");
  }

  // Analyse AI Coordinator
  let decision: PartnerDecision =
      request.activeUsers > 1000 ? "AUTO_ACCEPTED" :
      request.activeUsers < 100 ? "AUTO_REJECTED" :
      "PENDING_AI";

  request.status = decision;

  // Audit TS-safe
  audit("ONBOARD_REQUEST" as AuditEvent, { uuid, decision, timestamp: new Date() });

  // Notification wallet partnersigner (mock, sans emoji)
  console.log("Notification partnersigner: Request " + uuid + " => " + decision);

  return { uuid, decision };
};
