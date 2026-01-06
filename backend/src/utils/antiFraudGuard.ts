import { audit } from "./auditLogger.js";

const DAILY_LIMIT = 10000;

const userDaily: Record<string, number> = {};

export const antiFraudCheck = (
  userId: string,
  amount: number
): boolean => {
  if (amount <= 0) {
    audit("FRAUD_BLOCK", { userId, reason: "INVALID_AMOUNT", amount });
    return false;
  }

  userDaily[userId] = (userDaily[userId] || 0) + amount;

  if (userDaily[userId] > DAILY_LIMIT) {
    audit("FRAUD_BLOCK", {
      userId,
      reason: "DAILY_LIMIT_EXCEEDED",
      amount
    });
    return false;
  }

  return true;
};
