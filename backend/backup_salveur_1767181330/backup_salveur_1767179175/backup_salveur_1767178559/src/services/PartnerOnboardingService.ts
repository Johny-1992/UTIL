import { PartnerRequest } from '../models/partnerRequest';

export class PartnerOnboardingService {

  simulate() {
    const mockRequest = {
      uuid: "SIM-" + Date.now(),
      name: "Test Partner",
      activeUsers: 1500
    } as any;

    const created = this.createRequest(mockRequest);
    const approved = this.approveRequest(created.uuid);

    return {
      created,
      approved,
      simulation: "SUCCESS"
    };
  }

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
