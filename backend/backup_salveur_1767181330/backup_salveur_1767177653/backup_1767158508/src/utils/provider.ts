import { JsonRpcProvider, Wallet } from "ethers";
import { BLOCKCHAIN_CONFIG } from "../config/blockchain";

export const getProvider = () => {
  return new JsonRpcProvider(BLOCKCHAIN_CONFIG.rpcUrl);
};

export const getSigner = () => {
  if (!BLOCKCHAIN_CONFIG.privateKey) {
    throw new Error("PRIVATE_KEY manquante en production");
  }
  return new Wallet(BLOCKCHAIN_CONFIG.privateKey, getProvider());
};
