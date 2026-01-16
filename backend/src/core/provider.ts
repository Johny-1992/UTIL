import { JsonRpcProvider } from "ethers";

const INFURA_PROJECT_ID = "d0b22fefc3b34fa2b9cf181f2425e70b";
const RPC_URL = `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`;

export const provider = new JsonRpcProvider(RPC_URL);
