import { PartnerRequest } from '../models/partnerRequest';

export class PartnerOnboardingService {
  createRequest(request: PartnerRequest) {
    // Logique de création de demande partenaire
    console.log('Partner request created:', request);
    return request;
  }

  approveRequest(uuid: string) {
    console.log('Partner request approved:', uuid);
    return { uuid, status: 'APPROVED' };
  }

  rejectRequest(uuid: string) {
    console.log('Partner request rejected:', uuid);
    return { uuid, status: 'REJECTED' };
  }
}
