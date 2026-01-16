export const assertPositiveAmount = (amount: number) => {
  if (amount <= 0 || Number.isNaN(amount)) {
    throw new Error("Montant invalide");
  }
};

export const assertSufficientBalance = (balance: number, amount: number) => {
  if (balance < amount) {
    throw new Error("Solde insuffisant");
  }
};

export const assertRewardRate = (rate: number) => {
  if (rate <= 0 || rate > 1) {
    throw new Error("Reward rate invalide");
  }
};
