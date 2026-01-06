import { users, updateUserBalance } from '../models/userModel.js';
import { getPartnerRewardRate } from '../models/partnerModel.js';
import { audit } from '../utils/auditLogger.js';
import { antiFraudCheck } from '../utils/antiFraudGuard.js';

export const calculateRewards = (
  partnerId: string,
  userId: string,
  amountSpent: number
) => {
  if (!antiFraudCheck(userId, amountSpent)) {
    throw new Error("ANTI_FRAUD_BLOCK");
  }

  const rate = getPartnerRewardRate(partnerId);
  const utilEarned = amountSpent * rate;

  updateUserBalance(userId, utilEarned);

  audit("CALCULATE_REWARD", {
    partnerId,
    userId,
    amountSpent,
    utilEarned
  });

  return {
    utilEarned,
    newBalance: users[userId].balance
  };
};

export const transferUtil = (
  fromUserId: string,
  toUserId: string,
  amount: number
) => {
  if (!antiFraudCheck(fromUserId, amount)) {
    throw new Error("ANTI_FRAUD_BLOCK");
  }

  if (users[fromUserId].balance < amount) {
    throw new Error("INSUFFICIENT_BALANCE");
  }

  users[fromUserId].balance -= amount;
  users[toUserId].balance += amount;

  audit("TRANSFER_UTIL", { fromUserId, toUserId, amount });

  return true;
};

export const convertToUSDT = (userId: string, amount: number) => {
  if (!antiFraudCheck(userId, amount)) {
    throw new Error("ANTI_FRAUD_BLOCK");
  }

  if (users[userId].balance < amount) {
    throw new Error("INSUFFICIENT_BALANCE");
  }

  users[userId].balance -= amount;

  audit("CONVERT_USDT", { userId, amount });

  return { usdt: amount };
};
