import fs from 'fs';
import path from 'path';

export const LEDGER_PATH = path.join(process.cwd(), 'onchain_demo_ledger.json');

export interface OnchainDemoLedger {
  util: {
    balances: Record<string, number>;
  };
  partners: Record<string, any>;
  meta: {
    mode: string;
    createdAt: string;
    updatedAt: string;
  };
}

function createDefaultLedger(): OnchainDemoLedger {
  const now = new Date().toISOString();
  const ledger: OnchainDemoLedger = {
    util: { balances: {} },
    partners: {},
    meta: {
      mode: 'demo',
      createdAt: now,
      updatedAt: now,
    },
  };
  fs.writeFileSync(LEDGER_PATH, JSON.stringify(ledger, null, 2), 'utf-8');
  return ledger;
}

export function loadLedger(): OnchainDemoLedger {
  try {
    if (!fs.existsSync(LEDGER_PATH)) {
      return createDefaultLedger();
    }
    const content = fs.readFileSync(LEDGER_PATH, 'utf-8');
    const parsed = JSON.parse(content) as OnchainDemoLedger;
    if (!parsed.util || !parsed.util.balances || !parsed.partners || !parsed.meta) {
      return createDefaultLedger();
    }
    return parsed;
  } catch (err) {
    console.error('Erreur lecture ledger DEMO, recréation :', err);
    return createDefaultLedger();
  }
}

export function saveLedger(ledger: OnchainDemoLedger): void {
  ledger.meta.updatedAt = new Date().toISOString();
  fs.writeFileSync(LEDGER_PATH, JSON.stringify(ledger, null, 2), 'utf-8');
}
