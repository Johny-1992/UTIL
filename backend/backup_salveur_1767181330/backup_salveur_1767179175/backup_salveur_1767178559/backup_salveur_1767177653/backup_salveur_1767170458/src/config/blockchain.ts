export const BLOCKCHAIN_CONFIG = {
  rpcUrl: process.env.RPC_URL || "http://127.0.0.1:8545",
  privateKey: process.env.PRIVATE_KEY || "",
  network: process.env.NETWORK || "local",
};
