import { ethers } from "ethers";
import { loadLedger, saveLedger, Ledger } from '../onchain/ledger.js';
import { getOmniUtilContract } from '../utils/contracts.js';

// ⚠️ Clé privée testnet et RPC
const PRIVATE_KEY = process.env.TEST_WALLET_PRIVATE_KEY!;
const RPC_URL = "https://data-seed-prebsc-1-s1.binance.org:8545/";
const CONTRACT_ADDRESS = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1"; 

async function main() {
  // 1️⃣ Provider et wallet
  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

  // 2️⃣ Charger le contrat
  const omniUtilContract: any = getOmniUtilContract(provider).connect(wallet);

  // 3️⃣ Charger le Ledger
  let ledger: Ledger = loadLedger();
  console.log("Ledger initial :", ledger);

  // 4️⃣ Ajouter utilisateur et partenaire fictifs
  const userKey = "0xUserTest";
  const creatorKey = "0xCreatorTest";
  const partnerId = "partner_001";

  ledger.util.balances[userKey] = ledger.util.balances[userKey] || 0;
  ledger.util.balances[creatorKey] = ledger.util.balances[creatorKey] || 0;
  ledger.partners[partnerId] = ledger.partners[partnerId] || { updatedAt: new Date().toISOString() };

  saveLedger(ledger);
  console.log("Ledger après ajout :", loadLedger());

  // 5️⃣ Test claimReward
  try {
    const tx = await omniUtilContract.claimReward({ gasLimit: 300000 });
    console.log("claimReward tx hash :", tx.hash);
    await tx.wait();
    console.log("claimReward confirmée !");
  } catch (err) {
    console.error("Erreur claimReward :", err);
  }

  // 6️⃣ Test exchangeForService
  try {
    const tx2 = await omniUtilContract.exchangeForService(userKey, 10, { gasLimit: 300000 });
    console.log("exchangeForService tx hash :", tx2.hash);
    await tx2.wait();
    console.log("exchangeForService confirmée !");
  } catch (err) {
    console.error("Erreur exchangeForService :", err);
  }

  // 7️⃣ Test exchangeForUSDT
  try {
    const tx3 = await omniUtilContract.exchangeForUSDT(10, { gasLimit: 300000 });
    console.log("exchangeForUSDT tx hash :", tx3.hash);
    await tx3.wait();
    console.log("exchangeForUSDT confirmée !");
  } catch (err) {
    console.error("Erreur exchangeForUSDT :", err);
  }

  // 8️⃣ Test transferInEcosystem
  try {
    const tx4 = await omniUtilContract.transferInEcosystem(userKey, 5, { gasLimit: 300000 });
    console.log("transferInEcosystem tx hash :", tx4.hash);
    await tx4.wait();
    console.log("transferInEcosystem confirmée !");
  } catch (err) {
    console.error("Erreur transferInEcosystem :", err);
  }

  // 9️⃣ Vérifier Ledger final
  console.log("Ledger final :", loadLedger());
}

main().catch(err => console.error(err));
