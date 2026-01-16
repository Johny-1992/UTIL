import {
  analyzeUsage,
  analyzePartner,
  UsageEvent,
  PartnerProfile,
  FraudAnalysisResult,
} from '../fraud_detection';

export async function handleUsageEvent(event: UsageEvent): Promise<FraudAnalysisResult> {
  const analysis = analyzeUsage(event);
  console.log(JSON.stringify({ type: 'usage_event', event, analysis }));
  return analysis;
}

export async function handlePartnerProfile(profile: PartnerProfile): Promise<FraudAnalysisResult> {
  const analysis = analyzePartner(profile);
  console.log(JSON.stringify({ type: 'partner_profile', profile, analysis }));
  return analysis;
}
