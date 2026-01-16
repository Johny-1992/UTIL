import { ethers } from "ethers";
import OmniUtilArtifact from "../utils/omniutil_abi.json";

const RPC_URL = `https://mainnet.infura.io/v3/${process.env.INFURA_PROJECT_ID}`;
const CONTRACT_ADDRESS = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";

export const provider = new ethers.JsonRpcProvider(RPC_URL);

export const contract = new ethers.Contract(
  CONTRACT_ADDRESS,
  OmniUtilArtifact.abi, // 🔴 TRÈS IMPORTANT
  provider
);
