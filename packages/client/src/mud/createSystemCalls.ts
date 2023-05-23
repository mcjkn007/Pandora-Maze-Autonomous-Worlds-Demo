import { getComponentValue } from "@latticexyz/recs";
import { awaitStreamValue } from "@latticexyz/utils";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { worldSend, txReduced$, singletonEntity }: SetupNetworkResult,
  {  }: ClientComponents
) {
  const verifyGamePlay = async (opArray:number[]) => {
 
    try {
      const tx = await worldSend("verifyGamePlay", [opArray]);
      await awaitStreamValue(txReduced$, (txHash) => txHash === tx.hash);
      return true;
    } catch {
        return false;
    }
  };
  return {
    verifyGamePlay,
  };
}
