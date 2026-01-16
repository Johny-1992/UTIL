import { ethers } from "ethers";

const INFURA_PROJECT_ID = "d0b22fefc3b34fa2b9cf181f2425e70b";

export const provider = new ethers.JsonRpcProvider(
  `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`,
  1 // force mainnet → pas de "detect network"
);
