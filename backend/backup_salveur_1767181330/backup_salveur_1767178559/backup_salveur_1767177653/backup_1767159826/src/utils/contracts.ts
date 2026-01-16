import { Contract, Provider } from "ethers";
import OMNIUTIL_ABI from "./omniutil_abi.json";

export const OMNIUTIL_CONTRACT_ADDRESS = "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";

export const getOmniUtilContract = (provider: Provider): Contract => {
  return new Contract(OMNIUTIL_CONTRACT_ADDRESS, OMNIUTIL_ABI as any, provider);
};
