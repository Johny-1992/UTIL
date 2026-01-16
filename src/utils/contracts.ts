import { Contract, Provider } from "ethers";
import OmniUtilArtifact from "./omniutil_abi.json";

export const OMNIUTIL_CONTRACT_ADDRESS =
  "0xcFFDa93651Fc8a514e3B06A7a7bA4BEe663B8bA1";

export const getOmniUtilContract = (provider: Provider) => {
  return new Contract(
    OMNIUTIL_CONTRACT_ADDRESS,
    OmniUtilArtifact.abi,
    provider
  );
};

