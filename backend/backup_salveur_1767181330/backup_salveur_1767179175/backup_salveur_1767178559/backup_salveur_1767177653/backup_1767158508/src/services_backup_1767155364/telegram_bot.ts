// Récupérer le score de loyauté (mock)
export const getUserLoyaltyScore = (userAddress: string): number => {
  // En production: return db.users.find(u => u.address === userAddress)?.loyaltyScore || 100;
  return 100; // Valeur par défaut pour le mode démo
};
