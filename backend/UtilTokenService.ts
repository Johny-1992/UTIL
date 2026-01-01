// src/services/UtilTokenService.ts
import { JsonRpcProvider, Wallet } from 'ethers';

export class UtilTokenService {
  provider: JsonRpcProvider;
  wallet: Wallet;

  constructor() {
    if (!process.env.BSC_RPC_URL || !process.env.PRIVATE_KEY) {
      throw new Error("⚠️ Veuillez définir BSC_RPC_URL et PRIVATE_KEY dans le fichier .env");
    }

    this.provider = new JsonRpcProvider(process.env.BSC_RPC_URL);
    this.wallet = new Wallet(process.env.PRIVATE_KEY, this.provider);
  }

  async simulateReward() {
    console.log('Wallet address:', this.wallet.address);
    return { success: true };
  }
}
