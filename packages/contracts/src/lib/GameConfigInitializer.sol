// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { GameConfigComponent } from "../codegen/Tables.sol";
import { RemoveRuleType } from "../codegen/Types.sol";

library GameConfigInitializer {
  function init(IStore world) internal { 
    uint256 arg0 = 9;//slot
    arg0 += 2<<32;//composeNumbMin;
    arg0 += 7<<64;//composeNumbMax;
    arg0 += 16<<96;//typeNum;
    arg0 += 32<<128;//levelBlockInitNum;
    arg0 += 4<<160;//borderStep;
    arg0 += 8<<192;//levelNum;
    arg0 += 44<<224;//cardSize;
 
    uint256 arg1 = 9;//viewWidth
    arg1 += 9<<32;//viewHeight
    arg1 += 25<<64;//TotalRangeNum
    arg1 += 3<<96;//StageNum
    arg1 += uint8(RemoveRuleType.Discrete)<<128;//RemoveRule

    GameConfigComponent.set(world, arg0, arg1);
  }
}