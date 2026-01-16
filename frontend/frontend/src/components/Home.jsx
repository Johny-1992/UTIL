import React, { useEffect, useState } from "react";
import { connectWallet, getCurrentWallet } from "../web3/wallet";

export default function Home() {
  const [wallet, setWallet] = useState(null);

  useEffect(() => {
    async function checkWallet() {
      const current = await getCurrentWallet();
      if (current) setWallet(current);
    }
    checkWallet();
  }, []);

  const handleConnect = async () => {
    const address = await connectWallet();
    if (address) setWallet(address);
  };

  return (
    <div style={{ padding: "40px", textAlign: "center" }}>
      <h1>🚀 OmniUtil Web3</h1>

      {!wallet ? (
        <button onClick={handleConnect}>
          🔐 Connecter MetaMask
        </button>
      ) : (
        <>
          <p>✅ Wallet connecté :</p>
          <code>{wallet}</code>
        </>
      )}
    </div>
  );
}
