import { JsonRpcProvider, Wallet } from 'ethers';

/**
 * UtilTokenService
 * - Gestion blockchain (BSC / EVM)
 * - Gestion droit d’auteur (wallet propriétaire)
 * - Compatible mode démo / réel
 */
export class UtilTokenService {
  private provider?: JsonRpcProvider;
  private wallet?: Wallet;
  private ownerWallet: string;

  constructor() {
    // 🔐 Wallet propriétaire (obligatoire)
    if (!process.env.OWNER_WALLET) {
      throw new Error("OWNER_WALLET manquant dans .env");
    }
    this.ownerWallet = process.env.OWNER_WALLET;

    // 🌐 Blockchain optionnelle (mode démo possible)
    if (process.env.BSC_RPC_URL && process.env.PRIVATE_KEY) {
      this.provider = new JsonRpcProvider(process.env.BSC_RPC_URL);
      this.wallet = new Wallet(process.env.PRIVATE_KEY, this.provider);
    } else {
      console.warn("⚠️ Mode DEMO actif : BSC_RPC_URL ou PRIVATE_KEY manquant");
    }
  }

  /** 🔐 Wallet du propriétaire (droit d’auteur éternel – 1%) */
  getOwnerWalletAddress(): string {
    return this.ownerWallet;
  }

  /** 🧪 Simulation de reward (mode démo ou réel) */
  async simulateReward() {
    if (!this.wallet) {
      return {
        success: true,
        mode: "demo",
        ownerWallet: this.ownerWallet,
      };
    }

    console.log("Wallet blockchain actif :", this.wallet.address);

    return {
      success: true,
      mode: "onchain",
      wallet: this.wallet.address,
      ownerWallet: this.ownerWallet,
    };
  }
}
