import fs from 'fs';
import path from 'path';
import { loadLedger, saveLedger } from '../src/onchain/ledger';

const USER_WALLET_PATH = path.join(process.cwd(), '..', 'USER_WALLET.json');

function getCreatorWallet(): string {
  try {
    const raw = fs.readFileSync(USER_WALLET_PATH, 'utf-8');
    const parsed = JSON.parse(raw);
    if (parsed.wallet_address && typeof parsed.wallet_address === 'string') {
      return parsed.wallet_address;
    }
  } catch (err) {
    console.error('Erreur lecture USER_WALLET.json :', err);
  }
  // Fallback: wallet nul en démo
  return '0x0000000000000000000000000000000000000000';
}

export interface SyncRewardInput {
  userId: string;
  partnerId: string;
  utilAmount: number;
}

/**
 * Simule UTIL.mint + royalties 2% pour le créateur.
 * - 98% pour l'utilisateur
 * - 2% pour le wallet créateur (USER_WALLET.json)
 */
export function syncRewardDemo(input: SyncRewardInput) {
  const creatorWallet = getCreatorWallet();
  const ledger = loadLedger();

  const total = Math.floor(input.utilAmount);
  if (total <= 0) {
    throw new Error('utilAmount doit être > 0');
  }

  const creatorAmount = Math.floor(total * 0.02);
  const userAmount = total - creatorAmount;

  const userKey = `user:${input.userId}`;
  const creatorKey = `wallet:${creatorWallet}`;

  const userBefore = ledger.util.balances[userKey] || 0;
  const creatorBefore = ledger.util.balances[creatorKey] || 0;

  ledger.util.balances[userKey] = userBefore + userAmount;
  ledger.util.balances[creatorKey] = creatorBefore + creatorAmount;

  if (!ledger.partners[input.partnerId]) {
    ledger.partners[input.partnerId] = {
      id: input.partnerId,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
  } else {
    ledger.partners[input.partnerId].updatedAt = new Date().toISOString();
  }

  saveLedger(ledger);

  return {
    input,
    split: {
      total,
      userAmount,
      creatorAmount,
    },
    balances: {
      user: {
        key: userKey,
        before: userBefore,
        after: ledger.util.balances[userKey],
      },
      creator: {
        key: creatorKey,
        before: creatorBefore,
        after: ledger.util.balances[creatorKey],
      },
    },
    ledgerMeta: ledger.meta,
  };
}

/**
 * Enregistre un partenaire accepté par l'AI dans le ledger DEMO,
 * en simulant PartnerRegistry.registerPartner.
 */
export function registerPartnerDemo(proposal: any, analysis: any) {
  const ledger = loadLedger();
  const partnerId: string =
    proposal.partnerId ||
    proposal.id ||
    (proposal.name ? String(proposal.name).toLowerCase().replace(/\s+/g, '_') : 'unknown_partner');

  const existing = ledger.partners[partnerId];
  const now = new Date().toISOString();

  ledger.partners[partnerId] = {
    ...(existing || {}),
    partnerId,
    name: proposal.name,
    sector: proposal.sector,
    country: proposal.country,
    rewardRate: proposal.rewardRate,
    activeUsers: proposal.activeUsers,
    decision: 'auto_accept',
    score: analysis?.score,
    risk: analysis?.risk,
    reasons: analysis?.reasons || [],
    status: 'active',
    createdAt: existing?.createdAt || now,
    updatedAt: now,
  };

  saveLedger(ledger);

  return {
    partnerId,
    stored: ledger.partners[partnerId],
  };
}
