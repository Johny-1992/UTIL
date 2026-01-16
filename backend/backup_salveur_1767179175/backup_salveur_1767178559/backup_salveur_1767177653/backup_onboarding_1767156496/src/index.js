import { ethers } from "ethers";
import { OMNIUTIL_CONTRACT_ADDRESS, OMNIUTIL_ABI } from './utils/contracts.js';
import dotenv from 'dotenv';

dotenv.config();

// Initialiser le provider et le contrat
const provider = new ethers.JsonRpcProvider(process.env.BSC_RPC_URL || "https://data-seed-prebsc-1-s1.binance.org/");
export const omniUtilContract = new ethers.Contract(OMNIUTIL_CONTRACT_ADDRESS, OMNIUTIL_ABI, provider);
