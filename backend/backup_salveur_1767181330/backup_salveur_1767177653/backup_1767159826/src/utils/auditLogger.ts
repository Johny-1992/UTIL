export type AuditEvent =
  | "CALCULATE_REWARD"
  | "TRANSFER_UTIL"
  | "CONVERT_USDT"
  | "FRAUD_BLOCK";

export const audit = (event: AuditEvent, payload: Record<string, any>) => {
  console.log(`[AUDIT] ${event}`, payload);
};
