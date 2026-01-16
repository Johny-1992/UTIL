// wallet.js — Gestion MetaMask propre

export async function connectWallet() {
  if (!window.ethereum) {
    alert("MetaMask non détecté. Installe-le.");
    return null;
  }

  try {
    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    return accounts[0];
  } catch (error) {
    console.error("Erreur connexion MetaMask:", error);
    return null;
  }
}

export async function getCurrentWallet() {
  if (!window.ethereum) return null;

  const accounts = await window.ethereum.request({
    method: "eth_accounts",
  });

  return accounts.length > 0 ? accounts[0] : null;
}
