export interface UtilLedger {
  balances: Record<string, number>;
}

export interface Partner {
  updatedAt: string;
  // ajoute ici les champs nécessaires au partenaire
  [key: string]: any;
}

export interface LedgerMeta {
  // champs meta utilisés dans sync_chain.ts
  [key: string]: any;
}

export interface Ledger {
  util: UtilLedger;
  partners: Record<string, Partner>;
  meta: LedgerMeta;
}

let ledger: Ledger = {
  util: {
    balances: {}
  },
  partners: {},
  meta: {}
};

export const loadLedger = (): Ledger => {
  return ledger;
};

export const saveLedger = (newLedger: Ledger): void => {
  ledger = newLedger;
};
