import { FunctionFragment } from "ethers";
import { contract } from "../onchain/omniutil.contract";

export async function readAll() {
  const result: Record<string, any> = {};

  const fragments = contract.interface.fragments;

  for (const frag of fragments) {
    if (frag.type !== "function") continue;

    const fn = frag as FunctionFragment;

    if (
      (fn.stateMutability === "view" || fn.stateMutability === "pure") &&
      fn.inputs.length === 0
    ) {
      try {
        const name = fn.name;
        result[name] = await (contract as any)[name]();
      } catch (e) {
        result[fn.name] = "ERROR";
      }
    }
  }

  return result;
}
