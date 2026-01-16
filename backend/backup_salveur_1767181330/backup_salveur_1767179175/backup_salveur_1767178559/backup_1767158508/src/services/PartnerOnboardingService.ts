import { PartnerRequest } from "../models/partnerRequest";

export class PartnerOnboardingService {
    static onboardPartner(request: PartnerRequest) {
        console.log(`Partner ${request.name} onboarding initiated.`);
        request.status = "WAITING_SIGNER";
        return request;
    }
}
