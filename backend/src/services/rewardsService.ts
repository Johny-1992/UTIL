import { getPartnerRewardRate } from '../models/partnerModel';
import { getUtilPrice } from '../oracles/priceOracle';
import { updateUserBalance } from '../models/userModel';

// Simule les partenaires et utilisateurs
const partners = { p1: { rewardRate: 0.05 }, p2: { rewardRate: 0.10 } };
const users = { u1: { balance: 100 }, u2: { balance: 200 } };

// Conversion devise → USD
function convertToUSD(amount: number, currency: string): number {
  const rates: Record<string, number> = { USD: 1, EUR: 1.1, CDF: 0.0004 };
  return amount * (rates[currency] || 1);
}

// Calcul des récompenses
export async function calculateRewards(partnerId: string, userId: string, amountSpent: number, currency: string, utilPrice: number) {
  const partner = partners[partnerId];
  const rewardRate = partner.rewardRate;
  const amountInUSD = convertToUSD(amountSpent, currency);
  const utilEarned = (amountInUSD * rewardRate) / utilPrice;

  // Frais de 2% (1% créateur + 1% réseau)
  const fees = utilEarned * 0.02;
  const netUtil = utilEarned - fees;

  users[userId].balance += netUtil;
  return { utilEarned, fees, netUtil, newBalance: users[userId].balance };
}

// Transfert d'UTIL
export async function transferUtil(fromUserId: string, toUserId: string, amount: number) {
  if (users[fromUserId].balance < amount) {
    throw new Error("Solde insuffisant");
  }
  users[fromUserId].balance -= amount;
  users[toUserId].balance += amount;
  return { success: true, newBalanceFrom: users[fromUserId].balance, newBalanceTo: users[toUserId].balance };
}

// Conversion UTIL → USDT (simulée)
export async function convertToUSDT(userId: string, amount: number) {
  if (users[userId].balance < amount) {
    throw new Error("Solde insuffisant");
  }
  users[userId].balance -= amount;
  const usdtAmount = amount * 2; // Exemple : 1 UTIL = 2 USDT
  return { usdtAmount, txHash: "0x123..." };
}
